# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.NodeinfoController do
  use ActivityPubWeb, :controller

  alias MoodleNet.Config

  def schemas(conn, _params) do
    response = %{
      links: [
        %{
          rel: "http://nodeinfo.diaspora.software/ns/schema/2.0",
          href: MoodleNetWeb.base_url() <> "/nodeinfo/2.0"
        },
        %{
          rel: "http://nodeinfo.diaspora.software/ns/schema/2.1",
          href: MoodleNetWeb.base_url() <> "/nodeinfo/2.1"
        }
      ]
    }

    json(conn, response)
  end

  def nodeinfo(conn, %{"version" => "2.0"}) do
    conn
    |> put_resp_header(
      "content-type",
      "application/json; profile=http://nodeinfo.diaspora.software/ns/schema/2.0#; charset=utf-8"
    )
    |> json(%{"content" => "nil"})
  end

  def nodeinfo(conn, %{"version" => "2.1"}) do
    conn
    |> put_resp_header(
      "content-type",
      "application/json; profile=http://nodeinfo.diaspora.software/ns/schema/2.1#; charset=utf-8"
    )
    |> json(%{"content" => "nil"})
  end

  def nodeinfo(conn, _) do
    json(conn, %{"error" => "Nodeinfo schema version not handled"})
  end
end
