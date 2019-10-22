# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.UrlBuilder do
  @moduledoc """
  This module manages ActivityPub ID.
  """

  @doc """
  Prepare ActivityPub base URL (upon which object IDs, etc will be appended) based on base_url and ap_base_path
  """
  def base_url() do
    MoodleNetWeb.base_url()
    |> URI.parse()
    |> URI.merge(Application.get_env(:moodle_net, :ap_base_path, ""))
    |> to_string()
  end

  @type page :: {:page, integer, Map.t()}

  @doc """
  Create a URL using a local ID.

  A page can also be provided with its parameters.
  """
  @spec id(integer | page) :: binary
  def id({:page, local_id, params}) do
    id(local_id) <> "/page" <> params_to_query(params)
  end

  def id(local_id) when is_integer(local_id),
    do: append_bar_if_needed(base_url()) <> to_string(local_id)

  @doc """
  Predicate to check if given URL is on the same scheme, host and port as the
  current running instance.
  """
  @spec local?(binary) :: boolean
  def local?(nil), do: false
  def local?(id) when is_binary(id) do
    uri_id = URI.parse(id)
    uri_base = URI.parse(base_url())

    uri_id.scheme == uri_base.scheme and uri_id.host == uri_base.host and
      uri_id.port == uri_base.port
  end

  @doc """
  Get the local ID contained within the URL if there is one.

  If it is a page, a tuple is returned with the local ID and any URL parameters.
  """
  @spec get_local_id(binary) :: {:ok, integer | page} | :error
  def get_local_id(id) when is_binary(id) do
    uri_id = URI.parse(id)
    uri_base = URI.parse(base_url())

    with true <- same_base_url?(uri_base, uri_id),
         {:ok, id_string} <- truncate_base_path(uri_base.path, uri_id.path),
         {id, rest} <- Integer.parse(id_string) do
      virtual_id(id, rest, uri_id.query)
    else
      _ -> :error
    end
  end

  defp same_base_url?(uri_base, uri_id) do
    uri_id.scheme == uri_base.scheme and uri_id.host == uri_base.host and
      uri_id.port == uri_base.port
  end

  defp truncate_base_path(nil, uri_id_path) do
    if String.starts_with?(uri_id_path, "/") do
      {:ok, String.trim_leading(uri_id_path, "/")}
    else
      {:ok, uri_id_path}
    end
  end

  defp truncate_base_path(base, path_id) do
    base = append_bar_if_needed(base)

    if String.starts_with?(path_id, base) do
      {:ok, String.trim_leading(path_id, base)}
    else
      :error
    end
  end

  defp append_bar_if_needed(base) do
    if String.ends_with?(base, "/"), do: base, else: base <> "/"
  end

  defp virtual_id(id, "", nil), do: {:ok, id}

  defp virtual_id(id, "/page", nil), do: {:ok, {:page, id, %{}}}
  defp virtual_id(id, "/page", query), do: {:ok, {:page, id, URI.decode_query(query)}}
  defp virtual_id(_, _, _), do: :error

  defp params_to_query(nil), do: ""

  defp params_to_query(params = %{}) do
    params
    |> Map.take(["before", "after", "limit"])
    |> to_query()
  end

  defp to_query(params) when params == %{}, do: ""
  defp to_query(params), do: "?" <> URI.encode_query(params)
end
