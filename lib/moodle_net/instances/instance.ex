# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Instances.Instance do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "mn_instance" do
    field :ap_url_base, :string
  end

end
