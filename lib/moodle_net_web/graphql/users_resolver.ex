# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersResolver do
  @moduledoc """
  Performs the GraphQL User queries.
  """
  alias MoodleNetWeb.GraphQL
  alias MoodleNet.{
    Access,
    Activities,
    Actors,
    Collections,
    Communities,
    Follows,
    GraphQL,
    Likes,
    Repo,
    Users,
  }
  alias MoodleNet.GraphQL.{
    Flow,
    FetchPage,
    FetchPages,
    ResolvePage,
    ResolvePages,
  }
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Threads.{Comment, Comments, CommentsQueries}
  alias MoodleNet.Users.{Me, User}
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def username_available(%{username: username}, _info) do
    {:ok, Actors.is_username_available?(username)}
  end

  def me(_, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      {:ok, Me.new(user)}
    end
  end

  def me(%{token: _, me: me}, _, _), do: {:ok, me}

  def user(%{user_id: id}, info) do
    Users.one([:default, id: id, user: GraphQL.current_user(info)])
  end
  # def user(%{preferred_username: name}, info), do: Users.one(username: name)

  def user_edge(%Me{}=me, _, _info), do: {:ok, me.user}

  def comments_edge(%User{id: id}, page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_comments_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_comments_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    FetchPages.run(
      %FetchPages{
        queries: CommentsQueries,
        query: Comment,
        cursor_fn: &(&1.id),
        group_fn: &(&1.creator_id),
        page_opts: page_opts,
        base_filters: [user: user, creator_id: ids],
        data_filters: [order: :timeline_desc],
        count_filters: [group_count: :creator_id],
      }
    )
  end

  def fetch_comments_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    FetchPage.run(
      %FetchPage{
        queries: CommentsQueries,
        query: Comment,
        cursor_fn: &(&1.id),
        page_opts: page_opts,
        base_filters: [user: user, creator_id: ids],
        data_filters: [order: :timeline_desc],
      }
    )
  end

  def email_edge(me, _, _), do: {:ok, me.user.local_user.email}
  def wants_email_digest_edge(me, _, _), do: {:ok, me.user.local_user.wants_email_digest}
  def wants_notifications_edge(me, _, _), do: {:ok, me.user.local_user.wants_notifications}
  def is_confirmed_edge(me, _, _), do: {:ok, not is_nil(me.user.local_user.confirmed_at)}
  def is_instance_admin_edge(me, _, _), do: {:ok, me.user.local_user.is_instance_admin}

  def collection_follows_edge(%{id: id}, page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_collection_follows_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_collection_follows_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    FetchPages.run(
      %FetchPages{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        group_fn: &(&1.creator_id),
        page_opts: page_opts,
        base_filters: [user: user, creator_id: ids, join: :context, table: Collection],
        data_filters: [page: [desc: [created: page_opts]]],
        count_filters: [group_count: :context_id],
      }
    )
  end

  def fetch_collection_follows_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    FetchPage.run(
      %FetchPage{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [user: user, creator_id: ids, join: :context, table: Collection],
        data_filters: [page: [desc: [created: page_opts]]],
      }
    )
  end

  def community_follows_edge(%{id: id}, %{}=page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_community_follows_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_community_follows_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    FetchPages.run(
      %FetchPages{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &(&1.id),
        group_fn: &(&1.creator_id),
        page_opts: page_opts,
        base_filters: [user: user, creator_id: ids, join: :context, table: Community],
        data_filters: [page: [desc: [created: page_opts]]],
        count_filters: [group_count: :context_id]
      }
    )
  end

  def fetch_community_follows_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    FetchPage.run(
      %FetchPage{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [user: user, creator_id: ids, join: :context, table: Community],
        data_filters: [page: [desc: [created: page_opts]]],
      }
    )
  end

  ## followed users
  
  def user_follows_edge(%{id: id}, %{}=page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_user_follows_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_user_follows_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    FetchPages.run(
      %FetchPages{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        group_fn: &(&1.creator_id),
        page_opts: page_opts,
        base_filters: [user: user, creator_id: ids, join: :context, table: User],
        data_filters: [page: [desc: [created: page_opts]]],
        count_filters: [group_count: :context_id]
      }
    )
  end

  def fetch_user_follows_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    FetchPage.run(
      %FetchPage{
        queries: Follows.Queries,
        query: Follow,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [user: user, creator_id: ids, join: :context, table: User],
        data_filters: [page: [desc: [created: page_opts]]],
      }
    )
  end

  def inbox_edge(%User{id: id}=user, page_opts, info) do
    with {:ok, current_user} <- GraphQL.current_user_or_not_logged_in(info) do
      if id == current_user.id do
        Users.inbox(user, page_opts)
      else
        GraphQL.not_permitted()
      end
    end
  end

  def outbox_edge(%User{outbox_id: id}, page_opts, info) do
    # if GraphQL.in_list?(info) do
    #   with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
    #     batch {__MODULE__, :batch_outbox_edge, {page_opts, user}}, id, EdgesPages.getter(id)
    #   end
    # else
      with {:ok, page_opts} <- GraphQL.full_page_opts(page_opts) do
        single_outbox_edge(page_opts, info, id)
      end
    # end
  end

  def single_outbox_edge(page_opts, _info, id) do
    Activities.page(
      &(&1.id),
      page_opts,
      [join: :feed_activity,
       feed_id: id,
       table: default_outbox_query_contexts(),
       distinct: [desc: :id], # this does the actual ordering *sigh*
       order: :timeline_desc] # this is here because ecto has made questionable choices
    )
  end

  def follow_edge(follow, _, _), do: {:ok, follow}

  def creator_edge(%{creator_id: id}, _, info) do
    Flow.fields(__MODULE__, :fetch_creator_edge, id, info)
  end

  def fetch_creator_edge(info, ids) do
    user = GraphQL.current_user(info)
    {:ok, users} = Users.fields(&(&1.id), [:default, id: ids, user: user])
    users
  end

  def last_activity_edge(_parent,_,_info), do: {:ok, DateTime.utc_now()}

  ### Mutations

  def create_user(%{user: attrs}, info) do
    extra = %{is_public: true}
    with :ok <- GraphQL.guest_only(info),
         {:ok, user} <- Users.register(Map.merge(attrs, extra)) do
      {:ok, Me.new(user)}
    end
  end

  def update_profile(%{profile: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, user} <- Users.update(user, attrs) do
      {:ok, Me.new(user)}
    end
  end

  def delete(%{i_am_sure: true}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, _} <- Users.soft_delete(user) do
      {:ok, true}
    end
  end
  def delete(%{i_am_sure: false}, _info) do
    {:error, "Now is not the time to have second thoughts."}
  end

  def create_session(%{email: email, password: password}, info) do
    with :ok <- GraphQL.guest_only(info) do
      case Users.one([:default, email: email]) do
        {:ok, user} ->
          with {:ok, token} <- Access.create_token(user, password) do
            {:ok, %{token: token.id, me: Me.new(user)}}
          end
        _ ->
          Argon2.no_user_verify([])
          GraphQL.invalid_credential()
      end
    end
  end

  def delete_session(_, info) do
    with {:ok, _user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, _token} <- Access.hard_delete(info.context.auth_token) do
      {:ok, true}
    end
  end

  def delete_all_sessions(_, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {_count, _} <- Access.delete_tokens_for_user(user) do
      {:ok, true}
    end
  end

  def reset_password_request(%{email: email}, info) do
    with :ok <- GraphQL.guest_only(info),
         {:ok, user} <- Users.one([:default, email: email]),
         {:ok, _token} <- Users.request_password_reset(user) do
      {:ok, true}
    end
  end

  def reset_password(%{token: token, password: password}, info) do
    with :ok <- GraphQL.guest_only(info),
    	 {:ok, user} <- Users.claim_password_reset(token, password),
         {:ok, token} <- Access.unsafe_put_token(user) do
      {:ok, %{token: token.id, me: Me.new(user)}}
    end
  end

  def confirm_email(%{token: token}, info) do
    with :ok <- GraphQL.guest_only(info) do
      Repo.transact_with(fn ->
        with {:ok, user} <- Users.claim_email_confirm_token(token),
             {:ok, token} <- Access.unsafe_put_token(user) do
          {:ok, %{token: token.id, me: Me.new(user)}}
        end
      end)
    end
  end

  defp default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, Users)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

end
