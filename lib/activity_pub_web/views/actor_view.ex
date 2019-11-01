# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.ActorView do
  use ActivityPubWeb, :view
  alias ActivityPub.Utils

  def render("actor.json", %{actor: actor}) do
    {:ok, actor} = ActivityPub.Actor.ensure_keys_present(actor)
    {:ok, _, public_key} = ActivityPub.Keys.keys_from_pem(actor.keys)
    public_key = :public_key.pem_entry_encode(:SubjectPublicKeyInfo, public_key)
    public_key = :public_key.pem_encode([public_key])

    actor.data
    |> Map.put("url", actor.data["id"])
    |> Map.merge(%{
      "publicKey" => %{
        "id" => "#{actor.data["id"]}#main-key",
        "owner" => actor.data["id"],
        "publicKeyPem" => public_key
      }
    })
    |> Map.merge(Utils.make_json_ld_header())
  end
end
