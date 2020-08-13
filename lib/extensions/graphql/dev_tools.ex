defmodule MoodleNetWeb.GraphQL.DevTools do

  use ActivityPubWeb, :controller

  def schema(conn, _params) do

    sdl = Absinthe.Schema.to_sdl(MoodleNetWeb.GraphQL.Schema)
    # "schema {
    #   query {...}
    # }"

    html(conn,sdl)

  end
end
