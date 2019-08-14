# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.WebFinger do
  alias ActivityPub.Actor

  require ActivityPub.Guards

  def webfinger(resource) do
    host = MoodleNetWeb.base_url()
    regex = ~r/(acct:)?(?<username>[a-z0-9A-Z_\.-]+)@#{host}/

    with %{"username" => username} <- Regex.named_captures(regex, resource),
         {:ok, actor} <- Actor.get_by_username(username) do
      {:ok, represent_user(actor)}
    else
      _e ->
        with actor <- ActivityPub.get_by_id(resource, aspect: :actor),
             true <- ActivityPub.Guards.is_entity(actor) do
          {:ok, represent_user(actor)}
        else
          _e -> {:error, "Couldn't find"}
        end
    end
  end

  def represent_user(actor) do
    {:ok, actor} = ActivityPub.Utils.ensure_keys_present(actor)

    %{
      "subject" => "acct:#{actor.preferred_username}@#{MoodleNetWeb.base_url()}",
      "aliases" => [actor.id],
      "links" => [
        %{
          "rel" => "http://webfinger.net/rel/profile-page",
          "type" => "text/html",
          "href" => actor.id
        },
        %{"rel" => "self", "type" => "application/activity+json", "href" => actor.id},
        %{
          "rel" => "self",
          "type" => "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"",
          "href" => actor.id
        }
      ]
    }
  end
end
