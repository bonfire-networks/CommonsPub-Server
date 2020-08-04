# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Util do

    @doc "conditionally update a map"
    def maybe_put(map, _key, nil), do: map
    def maybe_put(map, key, value), do: Map.put(map, key, value)

    @doc "Replace a key in a map"
    def map_key_replace(%{} = map, key, new_key) do
      map
      |> Map.put(new_key, map[key])
      |> Map.delete(key)
    end
end
