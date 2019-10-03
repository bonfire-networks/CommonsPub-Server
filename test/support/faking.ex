# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Faking do
  alias MoodleNet.Test.Fake
  alias MoodleNet.{
    Actors,
    Comments,
    Communities,
    Collections,
    Meta,
    OAuth,
    Peers,
    Users,
    Localisation,
    Resources,
    Whitelists,
  }
  alias MoodleNet.Users.User

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

  def fake_user!(overrides \\ %{}, opts \\ []) when is_map(overrides) and is_list(opts) do
    {:ok, user} = Users.register(Fake.user(Fake.actor(overrides)), public_registration: true)
    user
    |> maybe_confirm_user_email(opts)
  end

  defp maybe_confirm_user_email(user, opts) do
    if Keyword.get(opts, :confirm_email) do
      {:ok, user} = Users.confirm_email(user)
      user
    else
      user
    end
  end

  def fake_token!(%User{}=user) do
    {:ok, auth} = OAuth.create_auth(user)
    {:ok, token} = OAuth.claim_token(auth)
    token
  end

  def fake_community!(actor, language, overrides \\ %{}) when is_map(overrides) do
    {:ok, community} = Communities.create(actor, language, Fake.community(overrides))
    community
  end

  def fake_collection!(actor, community, language, overrides \\ %{}) when is_map(overrides) do
    {:ok, collection} = Collections.create(community, actor, language, Fake.collection(overrides))
    collection
  end

  def fake_resource!(actor, collection, language, overrides \\ %{}) when is_map(overrides) do
    {:ok, resource} = Resources.create(collection, actor, language, Fake.resource(overrides))
    resource
  end

  def fake_thread!(parent, overrides \\ %{}) when is_map(overrides) do
    {:ok, thread} = Comments.create_thread(parent, Fake.thread(overrides))
    thread
  end

  def fake_comment!(thread, overrides \\ %{}) when is_map(overrides) do
    {:ok, comment} = Comments.create_comment(thread, Fake.comment(overrides))
    comment
  end
end
