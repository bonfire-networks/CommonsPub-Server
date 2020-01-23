# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Instance do
  @moduledoc "A proxy for everything happening on this instance"

  alias MoodleNet.{Feeds, Repo}
  alias MoodleNet.Activities
  
  def outbox() do
    Activities.edges_page(
      &(&1.id),
      feed_id: Feeds.instance_outbox_id(),
      order: :timeline_desc,
      table: default_outbox_query_contexts()      
    )
  end

  defp default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

end

