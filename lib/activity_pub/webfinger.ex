# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.WebFinger do
  alias ActivityPub.Actor
  alias ActivityPub.HTTP

  require Logger

  def webfinger(resource) do
    host = System.get_env("HOSTNAME") || MoodleNetWeb.Endpoint.host()
    regex = ~r/(acct:)?(?<username>[a-z0-9A-Z_\.-]+)@#{host}/

    with %{"username" => username} <- Regex.named_captures(regex, resource),
         {:ok, actor} <- Actor.get_by_username(username) do
      {:ok, represent_user(actor)}
    else
      _e ->
        actor = ActivityPub.get_by_id(resource, aspect: :actor)
        if actor do
          {:ok, represent_user(actor)}
        else
          {:error, "Couldn't find"}
        end
    end
  end

  def represent_user(actor) do
    {:ok, actor} = ActivityPub.Utils.ensure_keys_present(actor)

    %{
      "subject" => "acct:#{actor.preferred_username}@#{MoodleNetWeb.Endpoint.host()}",
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

  defp webfinger_from_json(doc) do
    data =
      Enum.reduce(doc["links"], %{"subject" => doc["subject"]}, fn link, data ->
        case {link["type"], link["rel"]} do
          {"application/activity+json", "self"} ->
            Map.put(data, "id", link["href"])

          {"application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"", "self"} ->
            Map.put(data, "id", link["href"])

          {_, "magic-public-key"} ->
            "data:application/magic-public-key," <> magic_key = link["href"]
            Map.put(data, "magic_key", magic_key)

          {"application/atom+xml", "http://schemas.google.com/g/2010#updates-from"} ->
            Map.put(data, "topic", link["href"])

          {_, "salmon"} ->
            Map.put(data, "salmon", link["href"])

          {_, "http://ostatus.org/schema/1.0/subscribe"} ->
            Map.put(data, "subscribe_address", link["template"])

          _ ->
            Logger.debug("Unhandled type: #{inspect(link["type"])}")
            data
        end
      end)

    {:ok, data}
  end

  def finger(account) do
    account = String.trim_leading(account, "@")

    domain =
      with [_name, domain] <- String.split(account, "@") do
        domain
      else
        _e ->
          URI.parse(account).host
      end

    address = "https://#{domain}/.well-known/webfinger?resource=acct:#{account}"

    with response <-
           HTTP.get(
             address,
             Accept: "application/jrd+json"
           ),
         {:ok, %{status: status, body: body}} when status in 200..299 <- response,
         {:ok, doc} <- Jason.decode(body) do
      webfinger_from_json(doc)
    else
      e ->
        Logger.debug(fn -> "Couldn't finger #{account}" end)
        Logger.debug(fn -> inspect(e) end)
        {:error, e}
    end
  end
end
