# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Faking do
  alias MoodleNet.Test.Fake
  alias MoodleNet.{
    Actors,
    Communities,
    Collections,
    Meta,
    Peers,
    Users,
    Localisation,
    Resources,
    Whitelists,
  }

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

  def fake_language!(overrides \\ %{}) do
    overrides
    |> Map.get(:id, "en")
    |> Localisation.language!()
  end

  def fake_peer!(overrides \\ %{}) when is_map(overrides) do
    {:ok, peer} = Peers.create(Fake.peer(overrides))
    peer
  end

  def fake_actor!(overrides \\ %{}) when is_map(overrides) do
    {:ok, actor} = Actors.create(Fake.actor(overrides))
    actor
  end

  def fake_user!(overrides \\ %{}) when is_map(overrides) do
    {:ok, actor} = Users.register(Fake.user(Fake.actor(overrides)))
    actor.alias.pointed
  end

  def fake_community!(actor, language, overrides \\ %{}) when is_map(overrides) do
    attrs =
      overrides
      |> Map.put_new_lazy(:creator_id, fn -> actor.id end)
      |> Map.put_new_lazy(:primary_language_id, fn -> language.id end)
      |> Fake.community()
    {:ok, community} = Communities.create(actor, language, attrs)
    community
  end

  def fake_collection!(actor, community, language, overrides \\ %{}) when is_map(overrides) do
    {:ok, collection} =
      overrides
      |> Map.put_new(:community_id, community.id)
      |> Map.put_new(:creator_id, actor.id)
      |> Map.put_new(:primary_language_id, language.id)
      |> Fake.collection()
    {:ok, community} = Collections.create(community, language, Fake.community(overrides))
    community
  end

  # def fake_resource!(overrides \\ %{}) when is_map(overrides) do
  #   actor = fake_actor!(overrides)
  #   language = fake_language!()
  #   collection = fake_collection!(overrides)
  #   {:ok, resource} = Resources.create(collection, actor, language, Fake.resource(overrides))
  #   resource
  # end

end
