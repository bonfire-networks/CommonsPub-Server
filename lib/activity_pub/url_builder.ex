defmodule ActivityPub.UrlBuilder do
  defp base_url() do
    # FIXME
    # MoodleNetWeb.base_url()
    "http://localhost:4000/"
  end

  def id(local_id) do
    "#{base_url()}/activity_pub/#{local_id}"
  end

  def actor_urls(id) do
    %{
      inbox: "#{id}/inbox",
      outbox: "#{id}/outbox",
      following: "#{id}/following",
      followers: "#{id}/followers",
      liked: "#{id}/liked",
      shared_inbox: "#{base_url()}/shared_inbox",
      proxy_url: "#{id}/proxy"
    }
  end

  def local?(nil), do: false
  def local?(id) when is_binary(id) do
    uri_id = URI.parse(id)
    uri_base = URI.parse(base_url())

    uri_id.scheme == uri_base.scheme and uri_id.host == uri_base.host and
      uri_id.port == uri_base.port
  end
end
