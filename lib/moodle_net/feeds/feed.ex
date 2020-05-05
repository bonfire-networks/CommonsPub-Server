# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.Feed do

  use MoodleNet.Common.Schema
  alias Ecto.Changeset
  alias MoodleNet.Feeds

  table_schema "mn_feed" do
  end

  @doc "Creates a new feed in the database"
  def create_changeset() do
    %__MODULE__{}
    |> Changeset.cast(%{},[])
  end    

  ### behaviour callbacks

  def context_module, do: Feeds

  def queries_module, do: Feeds.Queries

  def follow_filters, do: []

end
