defmodule ActivityPub.UrlBuilder do
  def id(local_id) do
    "#{MoodleNetWeb.base_url()}/activity_pub/#{local_id}"
  end

  def actor_urls(id) do
    %{
      inbox: "#{id}/inbox",
      outbox: "#{id}/outbox",
      following: "#{id}/following",
      followers: "#{id}/followers",
      liked: "#{id}/liked",
      shared_inbox: "#{MoodleNetWeb.base_url()}/shared_inbox",
      proxy_url: "#{id}/proxy",
    }
  end
end
