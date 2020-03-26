# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.GraphQL.Measurement do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  import_sdl path: "lib/valueflows/graphql/schemas/measurement.gql"

  def all_units(_, _, _) do
    items = [
      %{id: 1, label: "Euro", symbol: "$"},
      %{id: 2, label: "Dollar", symbol: "$"},
    ]

    {:ok, items}
  end


end
