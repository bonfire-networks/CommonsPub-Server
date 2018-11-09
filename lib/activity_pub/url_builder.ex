defmodule ActivityPub.UrlBuilder do
  def actor_uris(%ActivityPub.Actor{id: id}) do
    # FIXME
    base_url = MoodleNetWeb.base_url()
    %{
      uri: "#{base_url}/actors/#{id}",
      inbox_uri: "#{base_url}/actors/#{id}/inbox",
      outbox_uri: "#{base_url}/actors/#{id}/outbox",
      following_uri: "#{base_url}/actors/#{id}/following",
      followers_uri: "#{base_url}/actors/#{id}/followers",
      liked_uri: "#{base_url}/actors/#{id}/liked",
      shared_inbox_uri: "#{base_url}/shared_inbox",
      proxy_url: "#{base_url}/actors/#{id}/proxy",
    }
  end
end
