# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common do

  import ActivityPub.Guards
  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.{Policy,Repo}
  alias MoodleNet.Common.DeletionError
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  import Ecto.Query
  alias ActivityPub.Activities
  alias MoodleNet.Common.Changeset

  ### pagination

  def paginate(query, opts) do
  end

  ### liking

  def like(model, policy, activity, actor, thing) do
    attrs = like_attrs(actor, thing)
    Repo.transaction fn ->
      with :ok <- Policy.check(policy, [actor, thing, attrs]),
           {:ok, like} <- apply(Activities, activity, [actor, thing]) do
	Repo.insert(apply(model, :changeset, [attrs]))
      else
	other -> Repo.rollback(other)
      end
    end
  end

  def undo_like(model, activity, actor, thing) do
    Repo.transaction fn ->
      case Repo.get_by(model, like_attrs(actor, thing)) do
        nil -> Repo.rollback({:not_found, [thing.id, actor.id], "Activity"})
        like ->
	        # liked = undo_like_preload_liked(thing)
          # with :ok <- find_current_relation(liker, :liked, liked),
          #      {:ok, like} <- find_activity("Like", liker, liked),
          #      to <- calc_undo_like_to(liked),
          #      params = %{type: "Undo", actor: liker, object: like, to: to, _public: true},
          #      {:ok, activity} <- ActivityPub.new(params),
          #      {:ok, _activity} <- ActivityPub.apply(activity) do
          #   Repo.delete(like)
          # else
          #   {:error, other} -> Repo.rollback(other)
          #   other ->  Repo.rollback(other)
          # end
            Repo.rollback(:unimplemented)
      end
    end
  end

  def likes(model, policy, actor, filters \\ %{}) when has_type(actor, "Person") do
    with :ok <- apply(Policy, policy, [actor]),
      do: Repo.all(likes_query(model, filters))
  end

  defp like_attrs(actor, thing, base \\ %{}) do
    base
    |> Map.put(:liked_object_id, local_id(thing))
    |> Map.put(:liking_object_id, local_id(actor))
  end

  defp likes_query(model, filters), do: model

  ### flagging

  def flag(model, policy, activity, actor, thing, attrs) do
    attrs = flag_attrs(actor, thing, attrs)
    with :ok <- apply(Policy, policy, [actor, thing, attrs]) do
      apply(model, :changeset, [attrs])
      |> Repo.insert()
    end
  end

  def undo_flag(model, activity, actor, thing) do
    case Repo.get_by(model, flag_attrs(actor, thing)) do
      nil -> {:error, :not_found}
      flag -> Repo.delete(flag)
    end
  end

  def flags(model, policy, actor, filters \\ %{}) when has_type(actor, "Person") do
    with :ok <- apply(Policy, policy, [actor]),
      do: Repo.all(flags_query(model, filters))
  end

  defp flag_attrs(actor, thing, base \\ %{}) do
    base
    |> Map.put(:flagged_object_id, local_id(thing))
    |> Map.put(:flagging_object_id, local_id(actor))
  end

  defp flags_query(model, filters), do: filter_open(model, filters)
  
  # optionally filters by whether the flag is open or not

  defp filter_open(query, %{open: open}) when is_boolean(open),
    do: where(query, [f], f.open == ^open)

  defp filter_open(query, _), do: query

  ## Deletion

  @spec soft_delete(any()) :: {:ok, any()} | {:error, DeletionError.t()}
  @doc "Marks an entry as deleted in the database"
  def soft_delete(it), do: deletion_result(do_soft_delete(it))

  @spec soft_delete!(any()) :: any()
  @doc "Marks an entry as deleted in the database or throws a DeletionError"
  def soft_delete!(it), do: deletion_result!(do_soft_delete(it))

  defp do_soft_delete(it), do: Repo.update(Changeset.soft_delete_changeset(it))

  @spec hard_delete(any()) :: {:ok, any()} | {:error, DeletionError.t()}
  @doc "Deletes an entry from the database"
  def hard_delete(it), do: deletion_result(Repo.delete(it))

  @spec hard_delete!(any()) :: any()
  @doc "Deletes an entry from the database, or throws a DeletionError"
  def hard_delete!(it), do: deletion_result!(Repo.delete(it))

  def deletion_result({:error, e}), do: {:error, DeletionError.new(e)}
  def deletion_result(other), do: other

  def deletion_result!({:ok, val}), do: val
  def deletion_result!({:error, e}), do: throw DeletionError.new(e)

end
