# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Token do
  def random_key(length \\ 32) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def random_key_with_id(user_id, length \\ 32) do
    "#{user_id}_#{random_key(length)}"
  end

  def split_id_and_token(full_token) do
    with [id, token] <- String.split(full_token, "_", parts: 2),
         {id, _} <- Integer.parse(id) do
      {:ok, {id, token}}
    end
  end
end
