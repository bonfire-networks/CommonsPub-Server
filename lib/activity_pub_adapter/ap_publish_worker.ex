# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Workers.APPublishWorker do
  use ActivityPub.Workers.WorkerHelper, queue: "mn_ap_publish", max_attempts: 1

  require Logger

  alias CommonsPub.ActivityPub.Publisher
  alias CommonsPub.Blocks.Block
  alias CommonsPub.Flags.Flag
  alias CommonsPub.Follows.Follow
  alias CommonsPub.Likes.Like
  alias CommonsPub.Collections.Collection
  alias CommonsPub.Communities.Community
  alias CommonsPub.Meta.Pointers
  alias CommonsPub.Resources.Resource
  alias CommonsPub.Threads.Comment
  alias CommonsPub.Users.User

  @moduledoc """
  Module for publishing ActivityPub activities.

  Intended entry point for this module is the `__MODULE__.enqueue/2` function
  provided by `ActivityPub.Workers.WorkerHelper` module.

  Note that the `"context_id"` argument refers to the ID of the object being
  federated and not to the ID of the object context, if present.
  """

  @spec batch_enqueue(String.t(), list(String.t())) :: list(Oban.Job.t())
  @doc """
  Enqueues a number of jobs provided a verb and a list of string IDs.
  """
  def batch_enqueue(verb, ids) do
    Enum.map(ids, fn id -> enqueue(verb, %{"context_id" => id}) end)
  end

  @impl Worker
  def perform(%{args: %{"context_id" => context_id, "op" => "delete"}}) do
    # FIXME
    object =
      with {:error, _e} <-
             CommonsPub.Users.one(join: :character, preload: :character, id: context_id),
           {:error, _e} <-
             CommonsPub.Communities.one(join: :character, preload: :character, id: context_id),
           {:error, _e} <-
             CommonsPub.Collections.one(join: :character, preload: :character, id: context_id) do
        {:error, "not found"}
      end

    case object do
      {:ok, object} ->
        only_local(object, &publish/2, "delete")

      _ ->
        Pointers.one!(id: context_id)
        |> Pointers.follow!()
        |> only_local(&publish/2, "delete")
    end
  end

  def perform(%{args: %{"context_id" => context_id, "op" => verb}}) do
    Pointers.one!(id: context_id)
    |> Pointers.follow!()
    |> only_local(&publish/2, verb)
  end

  defp only_local(%Resource{collection_id: collection_id} = context, commit_fn, verb) do
    with {:ok, collection} <- CommonsPub.Collections.one(id: collection_id),
         {:ok, character} <- CommonsPub.Characters.one(id: collection.id),
         true <- is_nil(character.peer_id) do
      commit_fn.(context, verb)
    else
      _ ->
        :ignored
    end
  end

  defp only_local(%{is_local: true} = context, commit_fn, verb) do
    commit_fn.(context, verb)
  end

  defp only_local(%{character: %{peer_id: nil}} = context, commit_fn, verb) do
    commit_fn.(context, verb)
  end

  defp only_local(_, _, _), do: :ignored

  defp publish(%{__struct__: object_type} = local_object, verb) do
    if(
      !is_nil(object_type) and
        Code.ensure_loaded?(object_type) and
        Kernel.function_exported?(object_type, :context_module, 0)
    ) do
      object_context_module = apply(object_type, :context_module, [])

      if(
        Code.ensure_loaded?(object_context_module) and
          Kernel.function_exported?(object_context_module, :ap_publish_activity, 2)
      ) do
        # IO.inspect(function_exists_in: object_context_module)

        try do
          apply(object_context_module, :ap_publish_activity, [verb, local_object])
        rescue
          FunctionClauseError ->
            Logger.warn(
              "May not publish #{object_type} object - no function matching #{object_context_module}.ap_publish_activity(\"#{
                verb
              }\", object). Trying to fallback to CommonsPub.Workers.APPublishWorker.ap_activity/2"
            )

            ap_activity(local_object, verb)
        end
      else
        # temp fallback
        ap_activity(local_object, verb)
      end
    else
      Logger.warn(
        "Could not index #{object_type} object (not a known type or context_module undefined)"
      )

      :ignored
    end
  end

  # TODO: move Publisher.* funcs to context modules and deprecate the bellow

  defp ap_activity(%Collection{} = collection, "create"),
    do: CommonsPub.Collections.ap_publish_activity("create", collection)

  defp ap_activity(%Comment{} = comment, "create") do
    Publisher.comment(comment)
  end

  defp ap_activity(%Resource{} = resource, "create") do
    Publisher.create_resource(resource)
  end

  defp ap_activity(%Community{} = community, "create") do
    Publisher.create_community(community)
  end

  defp ap_activity(%Follow{} = follow, "create") do
    Publisher.follow(follow)
  end

  defp ap_activity(%Follow{} = follow, "delete") do
    Publisher.unfollow(follow)
  end

  defp ap_activity(%Flag{} = flag, "create") do
    Publisher.flag(flag)
  end

  defp ap_activity(%Block{} = block, "create") do
    Publisher.block(block)
  end

  defp ap_activity(%Block{} = block, "delete") do
    Publisher.unblock(block)
  end

  defp ap_activity(%Like{} = like, "create") do
    Publisher.like(like)
  end

  defp ap_activity(%Like{} = like, "delete") do
    Publisher.unlike(like)
  end

  defp ap_activity(%{__struct__: type} = character, "update")
       when type in [User, Community, Collection] do
    Publisher.update_character(character)
  end

  defp ap_activity(%User{} = user, "delete") do
    Publisher.delete_user(user)
  end

  defp ap_activity(%{__struct__: type} = character, "delete")
       when type in [Community, Collection] do
    Publisher.delete_character(character)
  end

  defp ap_activity(%{__struct__: type} = object, "delete") when type in [Comment, Resource] do
    Publisher.delete_comment_or_resource(object)
  end

  defp ap_activity(%{__struct__: type, id: id} = _object, verb) do
    Logger.error(
      "Unable to federate - Unsupported verb/object combination for AP publisher... object ID: #{id} ; verb: #{verb} ; object type: #{type}"
    )

    :ignored
  end

  defp ap_activity(object, verb) do
    Logger.error(
      "Unable to federate - Unsupported verb/object combination for AP publisher... verb: #{verb}}"
    )
    IO.inspect(object: object)

    :ignored
  end
end
