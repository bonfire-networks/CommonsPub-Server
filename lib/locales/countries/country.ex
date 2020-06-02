# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Locales.Country do
  use Ecto.Schema

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key{:id, :string, autogenerate: false}
  schema "countries" do
    # field(:id, :string)
    field(:name_eng, :string)
    field(:name_eng_formal, :string)
    field(:name_local, :string)

    field(:population, :integer)
    field(:capital, :string)
    field(:tld, :string)
    field(:tel_prefix, :string)

    # other IDs
    field(:id_3letter, :string)
    field(:id_iso, :integer)

    # these all should be FKs
    field(:continent_id, :string)
    field(:language_main, :string)
    field(:currency_id, :string)
    field(:main_tz, :string)

  end


end
