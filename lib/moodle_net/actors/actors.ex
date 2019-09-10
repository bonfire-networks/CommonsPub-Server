# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors do
  @doc """
  A Context for dealing with Actors.
  Actors come in several kinds:
  
  * Users
  * Communities

  """

  alias MoodleNet.Actors
  alias MoodleNet.Actors.Actor

  @attrs ~w(is_public)
  def attrs(attrs), do: Map.take(attrs, @attrs)
  
  def create(attrs \\ %{}) do
  end

  
  def update(attrs \\ %{}) do
  end

  def delete(%Actor{}=actor) do
  end

end
