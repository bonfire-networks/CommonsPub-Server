# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonResolver do

  alias Ecto.ULID
  alias MoodleNet.{
    Accounts,
    Actors,
    Collections,
    Common,
    Communities,
    Fake,
    Flags,
    Follows,
    GraphQL,
    Likes,
    Localisation,
    Meta,
    Repo,
    Users,
  }
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Flags.{AlreadyFlaggedError, Flag, NotFlaggableError}
  alias MoodleNet.Follows.{AlreadyFollowingError, Follow, NotFollowableError}
  alias MoodleNet.Likes.{AlreadyLikedError, Like, NotLikeableError}
  alias MoodleNet.Common.{NotFoundError, NotPermittedError}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Meta.Table
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User

  def created_at(%{id: id}, _, _) do
    ULID.timestamp(id)
  end

  def is_resolved(%Flag{}=flag, _, _), do: {:ok, not is_nil(flag.resolved_at)}

  def flag(%{flag_id: id}, info), do: Flags.fetch(id)

  def follow(%{follow_id: id}, info), do: Follows.fetch(id)

  def follow(parent, _, info) do
    case Map.get(parent, :follow) do
      nil -> {:ok, Fake.follow()}
      other -> {:ok, other}
    end
  end

  def like(%{like_id: id}, info), do: Likes.fetch(id)

  def like(parent,_, info) do
    case Map.get(parent, :like) do
      nil -> {:ok, Fake.like()}
      other -> {:ok, other}
    end
  end

  def creator(%{creator_id: id}, _, info), do: Users.fetch(id)

  def context(%{context_id: id}=it, _, info), do: get_context(it, &(&1.context_id))

  defp get_context(thing, accessor \\ &(&1.context_id)) do
    context_id = accessor.(thing)
    with {:ok, pointer} <- Meta.find(context_id),
         {:ok, thing} <- Meta.follow(pointer) do
      {:ok, loaded_context(thing)}
    end
  end
  
  def loaded_context(%Community{}=community), do: Communities.preload(community)
  def loaded_context(%Collection{}=collection), do: Collections.preload(collection)
  def loaded_context(%User{}=user), do: Users.preload_actor(user)
  def loaded_context(other), do: other

  # def tag(%{tag_id: id}, info) do
  #   {:ok, Fake.tag()}
  #   |> GraphQL.response(info)
  # end
  # def tag_category(%{tag_category_id: id}, info) do
  #   {:ok, Fake.tag_category()}
  #   |> GraphQL.response(info)
  # end
  # def tag_category(_, _, info) do
  #   {:ok, Fake.tag_category()}
  #   |> GraphQL.response(info)
  # end
  # def tagging(%{tagging_id: id}, info) do
  #   {:ok, Fake.tagging()}
  #   |> GraphQL.response(info)
  # end
  # def taggings(_, _, info) do
  #   {:ok, Fake.long_edge_list(&Fake.tagging/0)}
  #   |> GraphQL.response(info)
  # end

  # TODO: store community id where appropriate
  def create_flag(%{context_id: id, message: message}, info) do
    Repo.transact_with(fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- flaggable_entity(pointer) do
        Flags.create(me, thing, %{message: message})
      end
    end)
  end

  def create_like(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- likeable_entity(pointer) do
        Likes.create(me, thing, %{is_local: true})
      end
    end
  end

  def create_follow(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- followable_entity(pointer) do
        Follows.create(me, thing, %{is_local: true})
      end
    end
  end

  def is_public(parent, _, _), do: {:ok, not is_nil(parent.published_at)}
  def is_disabled(parent, _, _), do: {:ok, not is_nil(parent.disabled_at)}
  def is_deleted(parent, _, _), do: {:ok, not is_nil(parent.deleted_at)}

  def my_like(parent, _, info) do
    case GraphQL.current_user(info) do
      {:ok, user} ->
	with {:error, _} <- Likes.find(user, parent) do
          {:ok, nil}
	end
      _ -> {:ok, nil}
    end
  end

  def my_follow(parent, _, info) do
    case GraphQL.current_user(info) do
      {:ok, user} ->
	with {:error, _} <- Follows.find(user, parent) do
          {:ok, nil}
	end
      _ -> {:ok, nil}
    end
  end

  defp flaggable_entity(pointer) do
    %Table{schema: table} = Meta.points_to!(pointer)
    case table do
      Resource -> Meta.follow(pointer)
      Comment -> Meta.follow(pointer)
      Community -> Meta.follow(pointer)
      Collection -> Meta.follow(pointer)
      User -> Meta.follow(pointer)
      _ ->
	IO.inspect("unflaggable: #{table}")
	{:error, NotFlaggableError.new(pointer.id)}
    end
  end

  defp followable_entity(pointer) do
    %Table{schema: table} = Meta.points_to!(pointer)
    case table do
      Collection -> Meta.follow(pointer)
      Thread -> Meta.follow(pointer)
      Community -> Meta.follow(pointer)
      User -> Meta.follow(pointer)
      _ ->
	IO.inspect("unfollowable: #{table}")
	{:error, NotFollowableError.new(pointer.id)}
    end
  end

  defp likeable_entity(pointer) do
    %Table{schema: table} = Meta.points_to!(pointer)
    case table do
      Collection -> Meta.follow(pointer)
      Thread -> Meta.follow(pointer)
      Community -> Meta.follow(pointer)
      User -> Meta.follow(pointer)
      _ ->
	IO.inspect("unfollowable: #{table}")
	{:error, NotFollowableError.new(pointer.id)}
    end
  end

  # def followed(%Follow{}=follow,_,info)

  def delete(_,_info) do
    {:ok, true}
  end

  def tag(_, _, info) do
    {:ok, Fake.tag()}
    |> GraphQL.response(info)
  end

  def context(%{}=parent, _, info) do
    {:ok, Meta.follow!(Repo.preload(parent, :context).context)}
  end



  # def create_tagging(_, info) do
  #   {:ok, Fake.tagging()}
  #   |> GraphQL.response(info)
  # end
  def my_follow(parent, _, info) do
    case GraphQL.current_user(info) do
      {:ok, user} ->
        with {:error, _} <- Follows.find(user, parent) do
          {:ok, nil}
        end
      _ -> {:ok, nil}
    end
  end
  def my_like(parent, _, info) do
    case GraphQL.current_user(info) do
      {:ok, user} ->
        with {:error, _} <- Likes.find(user, parent) do
          {:ok, nil}
        end
      _ -> {:ok, nil}
    end
  end

  def my_flag(parent, _, info) do
    case GraphQL.current_user(info) do
      {:ok, user} ->
        with {:error, _} <- Flags.find(user, parent) do
          {:ok, nil}
        end
      _ -> {:ok, nil}
    end
  end

  def followers(parent, _, info), do: {:ok, GraphQL.edge_list([],0)}
  def likes(parent, _, info), do: {:ok, GraphQL.edge_list([],0)}
  def flags(parent, _, info), do: {:ok, GraphQL.edge_list([],0)}
  # def tags(parent, _, info) do
  #   {:ok, Fake.long_edge_list(&Fake.tagging/0)}
  #   |> GraphQL.response(info)
  # end

end
