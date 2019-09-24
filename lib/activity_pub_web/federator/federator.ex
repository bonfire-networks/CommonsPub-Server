# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.Federator do
  alias ActivityPub.Adapter
  alias ActivityPub.Utils
  alias ActivityPubWeb.Federator.Publisher
  alias ActivityPubWeb.Transmogrifier

  require Logger

  def incoming_ap_doc(params) do
    PleromaJobQueue.enqueue(:federator_incoming, __MODULE__, [:incoming_ap_doc, params])
  end

  def publish(activity, priority \\ 1) do
    PleromaJobQueue.enqueue(:federator_outgoing, __MODULE__, [:publish, activity], priority)
  end

  def perform(:publish, activity) do
    Logger.debug(fn -> "Running publish for #{activity["id"]}" end)

    with {:ok, actor} <- Adapter.get_actor_by_ap_id(activity.data["actor"]),
         {:ok, actor} <- Utils.ensure_keys_present(actor) do
      Publisher.publish(actor, activity)
    end
  end

  def perform(:incoming_ap_doc, params) do
    Logger.info("Handling incoming AP activity")

    params = Utils.normalize_params(params)

    Transmogrifier.handle_incoming(params)
  end

  def perform(type, _) do
    Logger.debug(fn -> "Unknown task: #{type}" end)
    {:error, "Don't know what to do with this"}
  end
end
