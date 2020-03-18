defmodule Taxonomy.Utils do

  use ActivityPubWeb, :controller

  def test(conn, _params) do


    json(conn,"ok")

  end
end
