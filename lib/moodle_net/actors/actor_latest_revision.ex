# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.ActorLatestRevision do

  use MoodleNet.Common.Schema
  alias MoodleNet.Actors.{Actor, ActorRevision, ActorLatestRevision}

  view_schema "mn_actor_latest_revision" do
    belongs_to :revision, ActorRevision, primary_key: true
    belongs_to :actor, Actor
    timestamps(updated_at: false)
  end

  @doc "Creates a fake ActorLatestRevision so we maintain ecto's format for linked data"
  def forge(%ActorRevision{id: revision_id, actor_id: actor_id, inserted_at: inserted_at}=revision) do
    %ActorLatestRevision{
      actor_id: actor_id,
      revision_id: revision_id,
      revision: revision,
      inserted_at: inserted_at,
    }
  end

end
