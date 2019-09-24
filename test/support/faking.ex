# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Faking do
  alias MoodleNet.Test.Fake
  alias MoodleNet.{Actors,Meta,Peers,Users,Repo}
  alias MoodleNet.Peers.Peer
  alias MoodleNet.Users.User
  alias MoodleNet.Whitelists
  alias MoodleNet.Whitelists.{RegisterEmailDomainWhitelist, RegisterEmailWhitelist}

  def fake_register_email_domain_whitelist!(domain \\ Fake.domain())
  when is_binary(domain) do
    {:ok, wl} = Whitelists.create_register_email_domain(domain)
    wl
  end

  def fake_register_email_whitelist!(email \\ Fake.email())
  when is_binary(email) do
    {:ok, wl} = Whitelists.create_register_email(email)
    wl
  end

  def fake_peer!(overrides \\ %{}) when is_map(overrides) do
    fake_meta!(Peer, &Peers.create/2, Fake.peer(overrides))
  end

  def fake_actor!(overrides \\ %{}) when is_map(overrides) do
    fake_meta!(Actor, &Actors.create/2, Fake.actor(overrides))
  end

  def fake_user!(overrides \\ %{}) when is_map(overrides) do
    fake_meta!(User, &Users.create/2, Fake.user(overrides))
  end

  defp fake_meta!(table_id, create_fn, params) do
    pointer = Meta.point_to!(table_id)
    {:ok, val} = create_fn.(pointer, params)
    val
  end

end
