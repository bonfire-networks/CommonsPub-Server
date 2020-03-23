# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.GraphQL.Measurement do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  import_sdl path: "lib/valueflows/graphql/schemas/measurement.gql"

  # __MODULE__.__absinthe_blueprint__ # to see the generated type definitions

  def hydrate(%{identifier: :all_units}, [%{identifier: :measurement_query} | _]) do
    Logger.info("hydrating all_units")
    {:resolve, &__MODULE__.all_units/3}
  end

  def all_units(_, _, _) do
    items = [
      %{id: "eur", label: "Euro", symbol: "$"},
      %{id: "usd", label: "Dollar", symbol: "$"},
    ]

    {:ok, items}
  end


end
