# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.GraphQL.Measurement do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}

  object :measurement_fields do

    import_sdl path: "lib/valueflows/graphql/schemas/measurement.gql"


    def hydrate(%{identifier: :all_units}, [%{identifier: :query} | _]) do
      {:resolve, &__MODULE__.allUnits/3}
    end

    def allUnits(_, _, _) do
      items = [
        %{id: "eur", label: "Euro", symbol: "$"},
        %{id: "usd", label: "Dollar", symbol: "$"},
      ]

      {:ok, items}
    end



  end

end
