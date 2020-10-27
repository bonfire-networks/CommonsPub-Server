# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Workers.APPublishWorker do
  use ActivityPub.Workers.WorkerHelper, queue: "mn_ap_publish", max_attempts: 1

  @moduledoc """
  Module for publishing ActivityPub activities.

  Intended entry point for this module is the `__MODULE__.enqueue/2` function
  provided by `ActivityPub.Workers.WorkerHelper` module.

  Note that the `"context_id"` argument refers to the ID of the object being
  federated and not to the ID of the object context, if present.
  """

  require Logger

  @doc """
  Enqueues a number of jobs provided a verb and a list of string IDs.
  """
  @spec batch_enqueue(String.t(), list(String.t())) :: list(Oban.Job.t())
  def batch_enqueue(verb, ids) do
    Enum.map(ids, fn id -> enqueue(verb, %{"context_id" => id}) end)
  end

  @impl Worker
  def perform(%{args: %{"op" => "delete", "context_id" => context_id}}) do
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
        only_local(object, "delete", &CommonsPub.ActivityPub.Publisher.publish/2)

      _ ->
        CommonsPub.Meta.Pointers.one!(id: context_id)
        |> CommonsPub.Meta.Pointers.follow!()
        |> only_local("delete", &CommonsPub.ActivityPub.Publisher.publish/2)
    end
  end

  def perform(%{args: %{"context_id" => context_id, "op" => verb}}) do
    CommonsPub.Meta.Pointers.one!(id: context_id)
    |> CommonsPub.Meta.Pointers.follow!()
    |> only_local(verb, &CommonsPub.ActivityPub.Publisher.publish/2)
  end

  defp only_local(%CommonsPub.Resources.Resource{context_id: context_id} = context, verb, commit_fn) do
    with {:ok, character} <- CommonsPub.Characters.one(id: context_id),
         true <- is_nil(character.peer_id) do
      commit_fn.(verb, context)
    else
      _ ->
        :ignored
    end
  end

  defp only_local(%{is_local: true} = context, verb, commit_fn) do
    commit_fn.(verb, context)
  end

  defp only_local(%{character: %{peer_id: nil}} = context, verb, commit_fn) do
    commit_fn.(verb, context)
  end

  defp only_local(_, _, _), do: :ignored


end
