# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Batching.Edges do
  @enforce_keys ~w(data)a
  defstruct @enforce_keys

  alias MoodleNet.Batching.Edges
  
  @type t :: %Edges{data: %{term => [term]}}

  @doc "Creates a new Edges from the data and a grouping key"
  @spec new(data :: [term], group_fn :: (map -> term)) :: t
  def new(data, group_fn) do
    %Edges{data: Enum.group_by(data, group_fn)}
  end

  @doc "Gets the result corresponding to the given key from the batch result or nil"
  @spec get(edges :: t, key :: term) :: term
  def get(%Edges{data: data}, key), do: {:ok, List.first(Map.get(data, key, []))}

  @doc "Returns a post-batch callback function which calls get with the provided key"
  @spec getter(key :: term) :: (%{term => [term]} -> term)
  def getter(key) do
    fn edges -> get(edges, key) end
  end

end
