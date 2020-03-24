# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.Fields do
  @enforce_keys ~w(data)a
  defstruct @enforce_keys

  alias MoodleNet.Common.Enums
  alias MoodleNet.GraphQL.Fields
  
  @type t :: %Fields{data: map}

  @doc "Creates a new Fields from the data and a grouping function"
  @spec new(data :: [term], group_fn :: (map -> term)) :: t
  def new(data, group_fn) do
    %Fields{data: Enums.group(data, group_fn)}
  end

  @doc """
  Returns the result corresponding to the given key, or the given default (or nil).
  """
  @spec get(fields :: t, key :: term) :: term
  @spec get(fields :: t, key :: term, default :: term) :: term
  def get(fields, key, default \\ nil)
  def get(%Fields{data: data}, %{id: key}, default) do
    {:ok, Map.get(data, key, default)}
  end
  def get(%Fields{data: data}, key, default) do
    {:ok, Map.get(data, key, default)}
  end

  @doc """
  Returns a post-batch callback function which calls get with the
  provided key and optional default value (or nil).
  """
  @spec getter(key :: term) :: (%{term => [term]} -> term)
  @spec getter(key :: term, default :: term) :: (%{term => [term]} -> term)
  def getter(key, default \\ nil) do
    fn fields -> get(fields, key, default) end
  end

end
