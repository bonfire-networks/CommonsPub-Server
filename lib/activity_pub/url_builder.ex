defmodule ActivityPub.UrlBuilder do
  defp base_url() do
    MoodleNetWeb.base_url()
  end

  def id(local_id) do
    "#{base_url()}/activity_pub/#{local_id}"
  end

  def local?(nil), do: false

  def local?(id) when is_binary(id) do
    uri_id = URI.parse(id)
    uri_base = URI.parse(base_url())

    uri_id.scheme == uri_base.scheme and uri_id.host == uri_base.host and
      uri_id.port == uri_base.port
  end

  def get_local_id(id) when is_binary(id) do
    uri_id = URI.parse(id)
    uri_base = URI.parse(base_url())

    with true <- uri_id.scheme == uri_base.scheme and uri_id.host == uri_base.host and
           uri_id.port == uri_base.port,
         "/activity_pub/" <> local_id <- uri_id.path,
         local_id = String.to_integer(local_id) do
      {:ok, local_id}
    else
      _ -> :error
    end
  end
end
