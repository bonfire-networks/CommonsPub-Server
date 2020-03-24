# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.Feed do

  alias Ecto.Changeset
  use MoodleNet.Common.Schema

  table_schema "mn_feed" do
  end

  @doc "Creates a new feed in the database"
  def create_changeset() do
    %__MODULE__{}
    |> Changeset.cast(%{},[])
  end    

end
