# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.HTTP do
  @moduledoc """
  Module for building and performing HTTP requests.
  """

  alias ActivityPub.HTTP.Connection
  alias ActivityPub.HTTP.RequestBuilder, as: Builder

  @type t :: __MODULE__

  @doc """
  Builds and perform http request.

  # Arguments:
  `method` - :get, :post, :put, :delete
  `url`
  `body`
  `headers` - a keyworld list of headers, e.g. `[{"content-type", "text/plain"}]`
  `options` - custom, per-request middleware or adapter options

  # Returns:
  `{:ok, %Tesla.Env{}}` or `{:error, error}`

  """
  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    try do
      options = process_sni_options(options, url)

      params = Keyword.get(options, :params, [])

      %{}
      |> Builder.method(method)
      |> Builder.headers(headers)
      |> Builder.opts(options)
      |> Builder.url(url)
      |> Builder.add_param(:body, :body, body)
      |> Builder.add_param(:query, :query, params)
      |> Enum.into([])
      |> (&Tesla.request(Connection.new(options), &1)).()
    rescue
      e ->
        {:error, e}
    catch
      :exit, e ->
        {:error, e}
    end
  end

  defp process_sni_options(options, nil), do: options

  defp process_sni_options(options, url) do
    uri = URI.parse(url)
    host = uri.host |> to_charlist()

    case uri.scheme do
      "https" -> options ++ [ssl: [server_name_indication: host]]
      _ -> options
    end
  end

  @doc """
  Makes a GET request

  see ActivityPub.HTTP.request/5
  """
  def get(url, headers \\ [], options \\ []), do:
    request(:get, url, "", headers, options)
end