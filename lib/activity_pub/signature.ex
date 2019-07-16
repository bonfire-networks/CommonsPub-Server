# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Signature do
  @behaviour HTTPSignatures.Adapter

  alias ActivityPub.Keys
  alias ActivityPub.Utils

  def fetch_public_key(conn) do

  end

  def refetch_public_key(conn) do

  end

  def sign(actor, headers) do
    with {:ok, actor} <- Utils.ensure_keys_present(actor),
         keys <- actor.keys,
         {:ok, private_key, _} <- Keys.keys_from_pem(keys) do
      HTTPSignatures.sign(private_key, actor.id <> "#main-key", headers)
    end
  end
end
