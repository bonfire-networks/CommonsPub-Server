# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonResolver do

  alias MoodleNet.{Accounts, Actors, Common, Fake, GraphQL, Localisation, Meta, Repo, Users}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Common.{
    AlreadyFlaggedError,
    AlreadyFollowingError,
    NotFlaggableError,
    NotFollowableError,
    NotFoundError,
    NotPermittedError,
  }
  alias MoodleNet.Common.{Flag,Follow,Like}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Meta.Table
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User

  def flag(%{flag_id: id}, info) do
    {:ok, Fake.flag()}
    |> GraphQL.response(info)
  end

  def follow(%{follow_id: id}, info) do
    {:ok, Fake.follow()}
    |> GraphQL.response(info)
  end

  def follow(_, _, info) do
    {:ok, Fake.follow()}
    |> GraphQL.response(info)
  end

  def like(%{like_id: id}, info) do
    {:ok, Fake.like()}
    |> GraphQL.response(info)
  end
  def tag(%{tag_id: id}, info) do
    {:ok, Fake.tag()}
    |> GraphQL.response(info)
  end
  def tag_category(%{tag_category_id: id}, info) do
    {:ok, Fake.tag_category()}
    |> GraphQL.response(info)
  end
  def tag_category(_, _, info) do
    {:ok, Fake.tag_category()}
    |> GraphQL.response(info)
  end
  def tagging(%{tagging_id: id}, info) do
    {:ok, Fake.tagging()}
    |> GraphQL.response(info)
  end
  def taggings(_, _, info) do
    {:ok, Fake.long_edge_list(&Fake.tagging/0)}
    |> GraphQL.response(info)
  end

  def create_follow(%{context_id: id}, info) do
    # Repo.transact_with fn ->
    #   with {:ok, me} <- GraphQL.current_user(info),
    #        {:ok, actor} <- Users.fetch_actor(me),
    #        {:ok, pointer} <- Meta.find(id),
    #        {:ok, thing} <- followable_entity(pointer) do
    #     case Common.follow(actor, thing, %{}) do
    #       {:ok, _} -> {:ok, true}
    #       other -> GraphQL.response(other, info)
    #     end
    #   else
    #     other -> GraphQL.response(other, info)
    #   end
    # end
    {:ok, Fake.follow()}
    |> GraphQL.response(info)
  end

  # def undo_follow(%{context_id: id}, info) do
  #   Repo.transact_with fn ->
  #     with {:ok, me} <- GraphQL.current_user(info),
  #          {:ok, actor} <- Users.fetch_actor(me),
  #          {:ok, pointer} <- Meta.find(id),
  #          {:ok, thing} <- flaggable_entity(pointer) do
  #       case Common.find_follow(actor, thing) do
  #         {:ok, follow} ->
  #           case Common.undo_follow(follow) do
  #             {:ok, _} -> {:ok, true}
  #             other -> GraphQL.response(other, info)
  #           end
  #         _ -> GraphQL.response({:error, NotFoundError.new(id)}, info)
  #       end
  #     else
  #       other -> GraphQL.response(other, info)
  #     end
  #   end
  # end

  # TODO: store community id where appropriate
  def create_flag(%{context_id: id, message: message}, info) do
    # Repo.transact_with fn ->
    #   with {:ok, me} <- GraphQL.current_user(info),
    #        {:ok, actor} <- Users.fetch_actor(me),
    #        {:ok, pointer} <- Meta.find(id),
    #        {:ok, thing} <- flaggable_entity(pointer) do
    #     case Common.flag(actor, thing, %{message: reason}) do
    #       {:ok, _} -> {:ok, true}
    #       other -> GraphQL.response(other, info)
    #     end
    #   else
    #     other -> GraphQL.response(other, info)
    #   end
    # end 
    {:ok, Fake.flag()}
    |> GraphQL.response(info)
  end

  # def undo_flag(%{context_id: id}, info) do
  #   Repo.transact_with fn ->
  #     with {:ok, me} <- GraphQL.current_user(info),
  #          {:ok, actor} <- Users.fetch_actor(me),
  #          {:ok, pointer} <- Meta.find(id),
  #          {:ok, thing} <- flaggable_entity(pointer) do
  #       case Common.find_flag(actor, thing) do
  #         {:ok, flag} ->
  #           case Common.resolve_flag(flag) do
  #             {:ok, _} -> {:ok, true}
  #             other -> GraphQL.response(other, info)
  #           end
  #         _ -> GraphQL.response({:error, NotFoundError.new(id)}, info)
  #       end
  #     else
  #       other -> GraphQL.response(other, info)
  #     end
  #   end
  # end

  def create_like(%{context_id: id}, info) do
    # Repo.transact_with fn ->
    #   with {:ok, me} <- GraphQL.current_user(info),
    #        {:ok, actor} <- Users.fetch_actor(me),
    #        {:ok, pointer} <- Meta.find(id),
    #        {:ok, thing} <- flaggable_entity(pointer) do
    #     case Common.like(actor, thing, %{}) do
    #       {:ok, _} -> {:ok, true}
    #       other -> GraphQL.response(other, info)
    #     end
    #   else
    #     other -> GraphQL.response(other, info)
    #   end
    # end
    {:ok, Fake.like()}
    |> GraphQL.response(info)
  end

  # def undo_like(%{context_id: id}, info) do
  #   Repo.transact_with fn ->
  #     with {:ok, me} <- GraphQL.current_user(info),
  #          {:ok, actor} <- Users.fetch_actor(me),
  #          {:ok, pointer} <- Meta.find(id),
  #          {:ok, thing} <- flaggable_entity(pointer) do
  #       case Common.find_like(actor, thing) do
  #         {:ok, _} -> {:ok, true}
  #         other -> GraphQL.response(other, info)
  #       end
  #     else
  #       other -> GraphQL.response(other, info)
  #     end
  #   end
  # end

  defp flaggable_entity(pointer) do
    %Table{schema: table} = Meta.points_to!(pointer)
    case table do
      Resource -> Meta.follow(pointer)
      Comment -> Meta.follow(pointer)
      Collection -> Meta.follow(pointer)
      Actor -> Meta.follow(pointer)
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
      Actor ->
        with {:ok, actor} <- Meta.follow(pointer),
             {:ok, pointer2} <- Meta.find(actor.alias_id) do
          %Table{schema: table2} = Meta.points_to!(pointer2)
          case table2 do
            Community -> {:ok, actor}
            _ ->
	      IO.inspect("unfollowable via actor: #{table}")
	      {:error, NotFollowableError.new(pointer.id)}
          end
        end
      _ ->
	IO.inspect("unfollowable: #{table}")
	{:error, NotFollowableError.new(pointer.id)}
    end
  end

  defp likeable_entity(pointer) do
    %Table{schema: table} = Meta.points_to!(pointer)
  end

  # def followed(%Follow{}=follow,_,info)

  def delete(_,_info) do
    {:ok, true}
  end

  def tag(_, _, info) do
    {:ok, Fake.tag()}
    |> GraphQL.response(info)
  end

  def context(%Follow{}=follow, _, info) do
    case Map.get(follow, :context) do
      nil -> {:ok, Fake.follow_context()}
      context -> {:ok, context}
    end
    |> GraphQL.response(info)
  end
  def context(%Flag{}, _, info) do
    {:ok, Fake.flag_context()}
    |> GraphQL.response(info)
  end
  def context(%Like{}, _, info) do
    {:ok, Fake.like_context()}
    |> GraphQL.response(info)
  end
  # def context(%Tagging{}, _, info) do
  #   {:ok, Fake.tagging_context()}
  #   |> GraphQL.response(info)
  # end

  def create_tagging(_, info) do
    {:ok, Fake.tagging()}
    |> GraphQL.response(info)
  end
  def my_follow(parent, _, info) do
    {:ok, Fake.follow()}
    |> GraphQL.response(info)
  end
  def my_like(parent, _, info) do
    {:ok, Fake.like()}
    |> GraphQL.response(info)
  end
  def followers(parent, _, info) do
    {:ok, Fake.long_edge_list(&Fake.follow/0)}
    |> GraphQL.response(info)
  end
  def likes(parent, _, info) do
    {:ok, Fake.long_edge_list(&Fake.like/0)}
    |> GraphQL.response(info)
  end
  def flags(parent, _, info) do
    {:ok, Fake.long_edge_list(&Fake.flag/0)}
    |> GraphQL.response(info)
  end
  def tags(parent, _, info) do
    {:ok, Fake.long_edge_list(&Fake.tagging/0)}
    |> GraphQL.response(info)
  end

end
