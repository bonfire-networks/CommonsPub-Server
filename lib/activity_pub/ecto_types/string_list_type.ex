# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.StringListType do
  @moduledoc """
  FIXME: this module probably is not needed anymore
  """

  @behaviour Ecto.Type

  def type, do: {:array, :string}

  def cast(list) do
    list = List.wrap(list)
    Ecto.Type.cast(type(), list)
  end

  def load(list), do: Ecto.Type.load(type(), list)
  def dump(list), do: Ecto.Type.dump(type(), list)
end
