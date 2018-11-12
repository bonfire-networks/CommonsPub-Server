defmodule ActivityPubWeb.ActorView do
  use ActivityPubWeb, :view

  def render("show.json", %{actor: actor}) do
    %{
      "@context": [
        "https://www.w3.org/ns/activitystreams",
        "https://w3id.org/security/v1",
        %{
          sensitive: "as:sensitive",
          Hashtag: "as:Hashtag",
          toot: "http://joinmastodon.org/ns#",
          Emoji: "toot:Emoji"
        }
      ],
      id: actor.uri,
      type: actor.type,
      following: actor.following_uri,
      followers: actor.followers_uri,
      inbox: actor.inbox_uri,
      outbox: actor.outbox_uri,
      preferredUsername: actor.preferred_username,
      name: actor.name,
      summary: actor.summary,
      url: actor.uri,
      publicKey: %{
        id: "#{actor.uri}#main-key",
        owner: actor.uri,
        publicKeyPem: "TODO"
      },
      endpoints: %{sharedInbox: actor.shared_inbox_uri},
      icon: nil,
      image: nil
    }
  end
end
