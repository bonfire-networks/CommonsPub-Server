# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Mix.Tasks.MoodleNet.GenerateCanonicalUrls do
  use Mix.Task
  require Logger
  alias ActivityPub.Actor
  alias ActivityPub.Object
  alias MoodleNet.Communities
  alias MoodleNet.Collections
  alias MoodleNet.Resources

  @shortdoc "Generates canonical URLs for local objects that don't have one"

  @usage "mix moodle_net.generate_canonical_urls"

  @moduledoc """
  This mix task is intended for instances that were launched before setting canonical URLs at object publish was implemented.
  Note: it will only update resources that were already published.

  Usage:

    % #{@usage}
  """

  def start_app do
    Application.put_env(:phoenix, :serve_endpoints, false, persistent: true)
    {:ok, _} = Application.ensure_all_started(:moodle_net)
  end

  defp update_communities() do
    {:ok, coms} = Communities.many(:default)
    coms = Enum.filter(coms, fn com -> is_nil(com.actor.peer_id) and is_nil(com.actor.canonical_url) end)
    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")

    Enum.each(coms, fn com ->
      url = MoodleNetWeb.base_url() <> ap_base_path <> "/actors/#{com.actor.preferred_username}"
      Logger.info("updating community #{url}")
      Communities.update(com, %{canonical_url: url})
    end)
  end

  defp update_collections() do
    {:ok, cols} = Collections.many(:default)
    cols = Enum.filter(cols, fn col -> is_nil(col.actor.peer_id) and is_nil(col.actor.canonical_url) end)
    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")

    Enum.each(cols, fn col ->
      url = MoodleNetWeb.base_url() <> ap_base_path <> "/actors/#{col.actor.preferred_username}"
      Logger.info("updating collection #{url}")
      Collections.update(col, %{canonical_url: url})
    end)
  end

  defp update_resources() do
    {:ok, resources} = Resources.many()
    resources = Enum.filter(resources, fn x -> is_nil(x.canonical_url) end)

    Enum.each(resources, fn resource ->
      ap = ActivityPub.Object.get_cached_by_pointer_id(resource.id)

      if ap do
        url = ap.data["id"]
        Logger.info("updating resource #{url}")
        Resources.update(resource, %{canonical_url: url})
      end
    end)
  end

  def run(_args) do
    start_app()
    update_communities()
    update_collections()
    update_resources()
  end
end
