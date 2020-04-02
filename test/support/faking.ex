# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Faking do
  alias MoodleNet.Test.Fake
  alias MoodleNet.{
    Access,
    Activities,
    Actors,
    Communities,
    Collections,
    Flags,
    Follows,
    Features,
    Likes,
    Peers,
    Users,
    Localisation,
    Resources,
    Threads,
  }
  alias MoodleNet.Threads.Comments
  alias MoodleNet.Users.User
  import MoodleNet.Test.Trendy
  import Zest

  def fake_register_email_domain_access!(domain \\ Fake.domain())
  when is_binary(domain) do
    {:ok, wl} = Access.create_register_email_domain(domain)
    wl
  end

  def fake_register_email_access!(email \\ Fake.email())
  when is_binary(email) do
    {:ok, wl} = Access.create_register_email(email)
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

  def fake_activity!(user, context, overrides \\ %{}) do
    {:ok, activity} = Activities.create(user, context, Fake.activity(overrides))
    activity
  end

  def fake_actor!(overrides \\ %{}) when is_map(overrides) do
    {:ok, actor} = Actors.create(Fake.actor(overrides))
    actor
  end

  def fake_user!(overrides \\ %{}, opts \\ []) when is_map(overrides) and is_list(opts) do
    {:ok, user} = Users.register(Fake.user(overrides), public_registration: true)
    maybe_confirm_user_email(user, opts)
  end

  def fake_admin!(overrides \\ %{}, opts \\ []) do
    fake_user!(Map.put(overrides, :is_instance_admin, true), opts)
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
    {:ok, token} = Access.unsafe_put_token(user)
    token
  end

  def fake_community!(user, overrides \\ %{})
  def fake_community!(%User{}=user, %{}=overrides) do
    {:ok, community} = Communities.create(user, Fake.community(overrides))
    community
  end

  def fake_collection!(user, community, overrides \\ %{}) when is_map(overrides) do
    {:ok, collection} = Collections.create(user, community, Fake.collection(overrides))
    collection
  end

  def fake_resource!(user, collection, overrides \\ %{}) when is_map(overrides) do
    {:ok, resource} = Resources.create(user, collection, Fake.resource(overrides))
    resource
  end

  def fake_thread!(user, context, overrides \\ %{}) when is_map(overrides) do
    {:ok, thread} = Threads.create(user, context, Fake.thread(overrides))
    thread
  end

  def fake_comment!(user, thread, overrides \\ %{}) when is_map(overrides) do
    {:ok, comment} = Comments.create(user, thread, Fake.comment(overrides))
    comment
  end

  def fake_reply!(user, thread, comment, overrides \\ %{}) when is_map(overrides) do
    fake = Fake.comment(Map.put_new(overrides, :in_reply_to, comment.id))
    {:ok, comment} = Comments.create(user, thread, fake)
    comment
  end

  def some_fake_users!(opts \\ %{}, some_arg) do
    some(some_arg, fn -> fake_user!(opts) end)
  end

  def some_fake_communities!(opts \\ %{}, some_arg, users) do
    flat_pam(users, &some(some_arg, fn -> fake_community!(&1, opts) end))
  end

  def some_fake_resources!(opts \\ %{}, some_arg, users, collections) do
    flat_pam_product_some(users, collections, some_arg, &fake_resource!(&1, &2, opts))
  end

  def some_fake_collections!(opts \\ %{}, some_arg, users, communities) do
    flat_pam_product_some(users, communities, some_arg, &fake_collection!(&1, &2, opts))
  end

  def some_randomer_flags!(opts \\ %{}, some_arg, context) do
    users = some_fake_users!(opts, some_arg)
    pam(users, &flag!(&1, context, opts))
  end

  def some_randomer_follows!(opts \\ %{}, some_arg, context) do
    users = some_fake_users!(opts, some_arg)
    pam(users, &follow!(&1, context, opts))
  end

  def some_randomer_likes!(opts \\ %{}, some_arg, context) do
    users = some(some_arg, &fake_user!/0)
    pam(users, &like!(&1, context, opts))
  end

  def like!(user, context, args \\ %{}) do
    {:ok, like} = Likes.create(user, context, Fake.like_input(args))
    like
  end

  def flag!(user, context, args \\ %{}) do
    {:ok, flag} = Flags.create(user, context, Fake.flag_input(args))
    flag
  end

  def follow!(user, context, args \\ %{}) do
    {:ok, follow} = Follows.create(user, context, Fake.follow_input(args))
    follow
  end

  def feature!(user, context, args \\ %{}) do
    {:ok, feature} = Features.create(user, context, Fake.feature_input(args))
    feature
  end

end
