defmodule CommonsPub.GraphQL.DevTools do
  use ActivityPubWeb, :controller

  @schema CommonsPub.Web.GraphQL.Schema

  def schema(conn, _params) do
    sdl = Absinthe.Schema.to_sdl(@schema)
    # "schema {
    #   query {...}
    # }"

    html(conn, sdl)
  end
end
