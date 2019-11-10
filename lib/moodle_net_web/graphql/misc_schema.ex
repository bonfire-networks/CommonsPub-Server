# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.MiscSchema do
  @moduledoc """
  Stuff without a clear module
  """
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.Errors
  alias ActivityPub.Fetcher

  import_types(MoodleNetWeb.Schema.Types.Custom.JSON)

  object :web_metadata do
    field(:title, :string)
    field(:summary, :string)
    field(:image, :string)
    field(:embed_code, :string)
    field(:language, :string)
    field(:author, :string)
    field(:source, :string)
    field(:resource_type, :string)
  end

  object :fetched_object do
    field(:id, :string)
    field(:data, :json)
    field(:local, :boolean)
    field(:public, :boolean)
  end

  def fetch_web_metadata(%{url: url}, info) do
    with {:ok, _actor} <- current_actor(info) do
      case MoodleNet.MetadataScraper.fetch(url) do
        {:error, _} -> Errors.bad_gateway_error()
        ret -> ret
      end
    end
  end

  def fetch_object(%{url: url}, _info) do
    with {:ok, object} <- Fetcher.fetch_object_from_id(url) do
      ret = %{
        id: object.id,
        data: object.data,
        local: object.local,
        public: object.public
      }

      {:ok, ret}
    else
      {:error, e} -> {:error, e}
    end
  end

  @doc """
  FIXME: repeated code from moodlenetschema
  """
  defp current_user(%{context: %{current_user: nil}}), do: Errors.unauthorized_error()
  defp current_user(%{context: %{current_user: user}}), do: {:ok, user}

  defp current_actor(info) do
    case current_user(info) do
      {:ok, user} ->
        {:ok, user.actor}

      ret ->
        ret
    end
  end
end
