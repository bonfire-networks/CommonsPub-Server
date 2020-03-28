# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.GraphQL.Geolocation do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  import_sdl path: "lib/valueflows/graphql/schemas/geolocation.gql"

  # mix phx.gen.schema Valueflows.Geolocation vf_spatial_things name note mappable_address lat:float long:float alt:float --context-app valueflows

end
