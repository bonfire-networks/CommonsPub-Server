# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources.ResourceLatestRevision do

  use MoodleNet.Common.Schema
  alias MoodleNet.Resources.{Resource, ResourceRevision, ResourceLatestRevision}

  view_schema "mn_resource_latest_revision" do
    belongs_to :revision, ResourceRevision, primary_key: true
    belongs_to :resource, Resource
    timestamps(updated_at: false)
  end

  @doc "Creates a fake ResourceLatestRevision so we maintain ecto's format for linked data"
  def forge(%ResourceRevision{id: revision_id, resource_id: resource_id, inserted_at: inserted_at}=revision) do
    %ResourceLatestRevision{
      resource_id: resource_id,
      revision_id: revision_id,
      revision: revision,
      inserted_at: inserted_at,
    }
  end
end
