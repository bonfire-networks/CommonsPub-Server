defmodule MoodleNetWeb.GraphQL.CommonResolver do

  alias MoodleNet.GraphQL
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNet.{Accounts, Actors, Common, GraphQL, Meta, Repo, Users}
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
  alias MoodleNet.Communities.Community
  alias MoodleNet.Meta.Table
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User

  def follow(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, actor} <- Users.fetch_actor(me),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- followable_entity(pointer) do
        case Common.follow(actor, thing, %{}) do
          {:ok, _} -> {:ok, true}
          other -> GraphQL.response(other, info)
        end
      else
        other -> GraphQL.response(other, info)
      end
    end
  end

  def undo_follow(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, actor} <- Users.fetch_actor(me),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- flaggable_entity(pointer) do
        case Common.find_follow(actor, thing) do
          {:ok, follow} ->
            case Common.undo_follow(follow) do
              {:ok, _} -> {:ok, true}
              other -> GraphQL.response(other, info)
            end
          _ -> GraphQL.response({:error, NotFoundError.new(id)}, info)
        end
      else
        other -> GraphQL.response(other, info)
      end
    end
  end

  # TODO: store community id where appropriate
  def flag(%{context_id: id, reason: reason}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, actor} <- Users.fetch_actor(me),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- flaggable_entity(pointer) do
        case Common.flag(actor, thing, %{message: reason}) do
          {:ok, _} -> {:ok, true}
          other -> GraphQL.response(other, info)
        end
      else
        other -> GraphQL.response(other, info)
      end
    end 
  end

  def undo_flag(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, actor} <- Users.fetch_actor(me),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- flaggable_entity(pointer) do
        case Common.find_flag(actor, thing) do
          {:ok, flag} ->
            case Common.resolve_flag(flag) do
              {:ok, _} -> {:ok, true}
              other -> GraphQL.response(other, info)
            end
          _ -> GraphQL.response({:error, NotFoundError.new(id)}, info)
        end
      else
        other -> GraphQL.response(other, info)
      end
    end
  end

  def like(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, actor} <- Users.fetch_actor(me),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- flaggable_entity(pointer) do
        case Common.like(actor, thing, %{}) do
          {:ok, _} -> {:ok, true}
          other -> GraphQL.response(other, info)
        end
      else
        other -> GraphQL.response(other, info)
      end
    end
  end

  def undo_like(%{context_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, actor} <- Users.fetch_actor(me),
           {:ok, pointer} <- Meta.find(id),
           {:ok, thing} <- flaggable_entity(pointer) do
        case Common.find_like(actor, thing) do
          {:ok, _} -> {:ok, true}
          other -> GraphQL.response(other, info)
        end
      else
        other -> GraphQL.response(other, info)
      end
    end
  end

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
    # case table do
    # end
  end

  def followers(parent,_, info) do
    # case parent do
      
    # end
  end

  def i_follow(parent, _, info) do
    
  end

  def i_like(parent, _, info) do
    
  end

end
