# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Locale do
  use Ecto.Schema

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key{:id, :string, autogenerate: false}
  schema "languages" do
    # field(:id, :string)
    field(:main_name, :string)
    field(:sub_name, :string)
    field(:native_name, :string)
    field(:language_type, :string)
    field(:parent_language_id, :string)
    field(:main_country_id, :string)
    field(:speakers_mil, :float)
    field(:speakers_native, :float)
    field(:speakers_native_total, :float)
    field(:rtl, :boolean)
  end


end
