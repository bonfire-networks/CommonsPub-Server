# SPDX-License-Identifier: AGPL-3.0-only

defmodule Bonfire.Search.HTTP do
  require Logger
  alias ActivityPub.HTTP # FIXME

  def http_request(http_method, url, headers, nil) do
    http_request(http_method, url, headers, %{})
  end

  def http_request(http_method, url, headers, object) do
    if(http_method == :get) do
      query_str = URI.encode_query(object)
      get_url = url <> "?" <> query_str
      apply(HTTP, http_method, [get_url, headers])
    else
      # IO.inspect(object)
      json = Jason.encode!(object)
      # IO.inspect(json: json)
      apply(HTTP, http_method, [url, json, headers])
    end
  end

  def http_error(true, _http_method, _message, _object) do
    nil
  end

  if Mix.env() == :test do
    def http_error(_, http_method, message, _object) do
      Logger.info("Search - Could not #{http_method} objects")
      Logger.debug(inspect(message))
    end
  end

  if Mix.env() == :dev do
    def http_error(_, http_method, message, object) do
      Logger.error("Search - Could not #{http_method} objects:")
      Logger.debug(inspect(message))
      Logger.debug(inspect(object))
      {:error, message}
    end
  end

  def http_error(_, http_method, message, _object) do
    Logger.warn("Search - Could not #{http_method} object:")
    Logger.debug(inspect(message))
    :ok
  end
end
