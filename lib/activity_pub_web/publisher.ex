# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.Publisher do

  alias ActivityPub.HTTP
  alias ActivityPub.Instances
  alias ActivityPubWeb.Transmogrifier

  require ActivityPub.Guards, as: APG
  require Logger

  @behaviour ActivityPubWeb.Federator.Publisher

  def is_representable?(activity) when APG.is_entity(activity), do: true
  def is_representable?(_), do: false

  @doc """
  Publish a single message to a peer.  Takes a struct with the following
  parameters set:

  * `inbox`: the inbox to publish to
  * `json`: the JSON message body representing the ActivityPub message
  * `actor`: the actor which is signing the message
  * `id`: the ActivityStreams URI of the message
  """
  def publish_one(%{inbox: inbox, json: json, actor: actor, id: id} = params) do
    Logger.info("Federating #{id} to #{inbox}")
    host = URI.parse(inbox).host

    digest = "SHA-256=" <> (:crypto.hash(:sha256, json) |> Base.encode64())

    date =
      NaiveDateTime.utc_now()
      |> Timex.format!("{WDshort}, {0D} {Mshort} {YYYY} {h24}:{m}:{s} GMT")

    signature =
      ActivityPub.Signature.sign(actor, %{
        host: host,
        "content-length": byte_size(json),
        digest: digest,
        date: date
      })

    with {:ok, %{status: code}} when code in 200..299 <-
           result =
             HTTP.post(
               inbox,
               json,
               [
                 {"Content-Type", "application/activity+json"},
                 {"Date", date},
                 {"signature", signature},
                 {"digest", digest}
               ]
             ) do
      if !Map.has_key?(params, :unreachable_since) || params[:unreachable_since],
        do: Instances.set_reachable(inbox)

      result
    else
      {_post_result, response} ->
        unless params[:unreachable_since], do: Instances.set_unreachable(inbox)
        {:error, response}
    end
  end

  def publish(actor, activity) do
    data = Transmogrifier.prepare_outgoing(activity)
    json = Jason.encode!(data)
    inbox = nil
    unreachable_since = nil

    ActivityPubWeb.Federator.Publisher.enqueue_one(__MODULE__, %{
      inbox: inbox,
      json: json,
      actor: actor,
      id: activity.id,
      unreachable_since: unreachable_since
    })
  end

  def gather_webfinger_links(actor) do
    [
      %{"rel" => "self", "type" => "application/activity+json", "href" => actor.id},
      %{
        "rel" => "self",
        "type" => "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"",
        "href" => actor.id
      }
    ]
  end
end
