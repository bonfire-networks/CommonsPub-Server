# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Faking do
  alias MoodleNet.Test.Fake
  alias MoodleNet.{Actors, Communities, Collections, Meta, Peers, Users, Localisation, Resources}
  alias MoodleNet.Whitelists

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
    {:ok, user} = Users.register(Fake.user(overrides))
    user
  end

  def fake_community!(overrides \\ %{}) when is_map(overrides) do
    actor = fake_actor!(overrides)
    language = fake_language!()
    {:ok, community} = Communities.create(actor, language, Fake.community(overrides))
    community
  end

  def fake_collection!(overrides \\ %{}) when is_map(overrides) do
    # FIXME: allow setup of actor + community relationship
    actor = fake_actor!(overrides)
    language = fake_language!()
    community = fake_community!(overrides)
    {:ok, collection} = Collections.create(community, actor, language, Fake.collection(overrides))
    collection
  end

  def fake_resource!(overrides \\ %{}) when is_map(overrides) do
    actor = fake_actor!(overrides)
    language = fake_language!()
    collection = fake_collection!(overrides)
    {:ok, resource} = Resources.create(collection, actor, language, Fake.resource(overrides))
    resource
  end
end
