# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.Tag do
  use Ecto.Schema

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key{:id, :integer, autogenerate: false}
  schema "taxonomy_tags" do
    # field(:id, :string)
    field(:label, :string)
    field(:description, :string)
    field(:parent_tag_id, :integer)
  end


end
