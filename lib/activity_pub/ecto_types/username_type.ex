# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.UsernameType do
  @behaviour Ecto.Type

  def type, do: :string

  def cast(str) when is_binary(str) do
    if Regex.match?(~r(/^[a-z0-9]{3,20}$/), str),
      do: {:ok, str},
      else: :error
  end
  def cast(_), do: :error
  
  def load(list), do: Ecto.Type.load(type(), list)
  def dump(list), do: Ecto.Type.dump(type(), list)
end
