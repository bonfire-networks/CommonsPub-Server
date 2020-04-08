# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ContentMirror do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [validate_http_url: 2]
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  table_schema "mn_content_mirror" do
    field(:url, :string)
  end

  @cast ~w(url)a
  @required @cast

  def changeset(attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> validate_http_url(:url)
  end
end
