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
    Batching,
    Collections,
    Communities,
    Follows,
    GraphQL,
    Likes,
    Repo,
    Users,
  }
  alias MoodleNet.Batching.{Edges, EdgesPages}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.GraphQL.Flow
  alias MoodleNet.Threads.Comments
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

  def likes_edge(%{id: id}, page_opts, %{context: %{current_user: user}}=info) do
    if GraphQL.in_list?(info) do
      with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
        batch {__MODULE__, :batch_likes_edge, {page_opts,user}}, id, EdgesPages.getter(id)
      end
    else
      with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
        single_likes_edge(page_opts, user, id)
      end
    end
  end

  def single_likes_edge(page_opts, user, ids) do
    Likes.page(
      &(&1.id),
      page_opts,
      [user: user, context_id: ids],
      [order: :timeline_desc]
    )
  end

  def batch_likes_edge({page_opts, user}, ids) do
    {:ok, edges} = Likes.pages(
      &(&1.id),
      &(&1.creator_id),
      page_opts,
      [user: user, context_id: ids],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    edges
  end

  def me(%{token: _, me: me}, _, _), do: {:ok, me}

  def user(%{user_id: id}, %{context: %{current_user: user}}) do
    Users.one([:default, id: id, user: user])
  end
  # def user(%{preferred_username: name}, info), do: Users.one(username: name)

  def user_edge(%Me{}=me, _, _info), do: {:ok, me.user}

  def comments_edge(%User{id: id}, page_opts, %{context: %{current_user: user}}=info) do
    if GraphQL.in_list?(info) do
      with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
        batch {__MODULE__, :batch_comments_edge, {page_opts,user}}, id, EdgesPages.getter(id)
      end
    else
      with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
        single_comments_edge(page_opts, user, id)
      end
    end
  end

  def single_comments_edge(page_opts, %User{}=user, ids) do
    Comments.pages(
      &(&1.id),
      page_opts,
      [user: user, creator_id: ids],
      [order: :timeline_desc]
    )
  end

  def batch_comments_edge({page_opts,%User{}=user}, ids) do
    {:ok, pages} = Comments.pages(
      &(&1.id),
      &(&1.creator_id),
      page_opts,
      [user: user, creator_id: ids],
      [order: :timeline_desc],
      [group_count: :creator_id]
    )
    pages
  end

  def email_edge(me, _, _), do: {:ok, me.user.local_user.email}
  def wants_email_digest_edge(me, _, _), do: {:ok, me.user.local_user.wants_email_digest}
  def wants_notifications_edge(me, _, _), do: {:ok, me.user.local_user.wants_notifications}
  def is_confirmed_edge(me, _, _), do: {:ok, not is_nil(me.user.local_user.confirmed_at)}
  def is_instance_admin_edge(me, _, _), do: {:ok, me.user.local_user.is_instance_admin}

  def followed_collections_edge(%{id: id}, page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_followed_collections_edge, page_opts, id, info, opts)
  end

  def fetch_followed_collections_edge({page_opts, user}, ids) do
    {:ok, edges} = Follows.pages(
      &(&1.id),
      &(&1.creator_id),
      page_opts,
      [user: user, creator_id: ids, join: :context, table: Collection],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    edges
  end

  def fetch_followed_collections_edge(page_opts, user, ids) do
    Follows.page(
      &(&1.id),
      page_opts,
      [user: user, creator_id: ids, join: :context, table: Collection],
      [order: :timeline_desc]
    )
  end

  def collection_edge(%{context_id: id}, _, info) do
    Flow.fields(__MODULE__, :fetch_collection_edge, id, info)
  end

  def fetch_collection_edge(_, ids) do
    {:ok, edges} = Collections.fields(&(&1.id), [:default, id: ids, preload: :actor])
    edges
  end

  def followed_communities_edge(%{id: id}, %{}=page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_followed_communities_edge, page_opts, id, info, opts)
  end

  def fetch_followed_communities_edge({page_opts, user}, ids) do
    {:ok, edges} = Follows.pages(
      &(&1.creator_id),
      &(&1.id),
      page_opts,
      [user: user, creator_id: ids, join: :context, table: Community],
      [order: :timeline_desc, preload: :context],
      [group_count: :context_id]
    )
    edges
  end

  def fetch_followed_communities_edge(page_opts, user, ids) do
    Follows.page(
      &(&1.id),
      page_opts,
      [user: user, creator_id: ids, join: :context, table: Community],
      [order: :timeline_desc]
    )
  end

  def community_edge(%{context_id: id}, _, info) do
    Flow.fields(__MODULE__, :fetch_community_edge, id, info)
  end

  def fetch_community_edge(_, ids) do
    {:ok, edges} = Communities.fields(&(&1.id), [:default, id: ids])
    edges
  end

  ## followed users
  
  def followed_users_edge(%{id: id}, %{}=page_opts, %{context: %{current_user: user}}=info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_followed_users_edge, page_opts, id, info, opts)
  end

  def fetch_followed_users_edge({page_opts, user}, ids) do
    {:ok, edges} = Follows.pages(
      &(&1.creator_id),
      &(&1.id),
      page_opts,
      [user: user, creator_id: ids, join: :context, table: User],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    edges
  end

  def fetch_followed_users_edge(page_opts, user, ids) do
    Follows.page(
      &(&1.id),
      page_opts,
      [user: user, creator_id: ids, join: :context, table: User],
      [order: :timeline_desc]
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

  def outbox_edge(%User{outbox_id: id}, page_opts, %{context: %{current_user: user}}=_info) do
    # if GraphQL.in_list?(info) do
    #   with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
    #     batch {__MODULE__, :batch_outbox_edge, {page_opts, user}}, id, EdgesPages.getter(id)
    #   end
    # else
      with {:ok, page_opts} <- GraphQL.full_page_opts(page_opts) do
        single_outbox_edge(page_opts, user, id)
      end
    # end
  end

  def single_outbox_edge(page_opts, _user, id) do
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

  def fetch_creator_edge(user, ids) do
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
