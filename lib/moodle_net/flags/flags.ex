# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags do
  alias MoodleNet.{Activities, Common, Repo}
  # alias MoodleNet.FeedPublisher
  alias MoodleNet.Flags.{AlreadyFlaggedError, Flag, NotFlaggableError, Queries}
  alias MoodleNet.Meta.{Pointers, Table}
  alias MoodleNet.Users.User

  def one(filters), do: Repo.single(Queries.query(Flag, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Flag, filters))}

  defp valid_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:valid_contexts)
  end

  def create(
    %User{} = flagger,
    flagged,
    community \\ nil,
    %{is_local: is_local} = fields
  ) when is_boolean(is_local) do
    flagged = Pointers.maybe_forge!(flagged)
    %Table{schema: table} = Pointers.table!(flagged)
    if table in valid_contexts() do
      Repo.transact_with(fn ->
        case one([deleted: false, creator: flagger.id, context: flagged.id]) do
          {:ok, _} -> {:error, AlreadyFlaggedError.new(flagged.id)}
          _ -> really_create(flagger, flagged, community, fields)
        end
      end)
    else
      {:error, NotFlaggableError.new(flagged.id)}
    end
  end

  defp really_create(flagger, flagged, community, fields) do
    with {:ok, flag} <- insert_flag(flagger, flagged, community, fields),
         {:ok, _activity} <- insert_activity(flagger, flag, "created"),
         :ok <- publish(flagger, flagged, flag, community),
         :ok <- ap_publish(flagger, flag) do
      {:ok, flag}
    end
  end

  def update_by(%User{}, filters, updates) do
    Repo.update_all(Queries.query(Flag, filters), set: updates)
  end

  def soft_delete(%User{}=user, %Flag{}=flag) do
    Repo.transact_with(fn ->
      with {:ok, flag} <- Common.soft_delete(flag),
           :ok <- chase_delete(user, flag.id),
           :ok <- ap_publish(flag) do
        {:ok, flag}
      end      
    end)
  end

  def soft_delete_by(%User{}=user, filters) do
    with {:ok, _} <-
      Repo.transact_with(fn ->
        {_, ids} = update_by(user, [{:select, :id}, {:deleted, false} | filters], deleted_at: DateTime.utc_now())
        chase_delete(user, ids)
      end), do: :ok
  end

  defp chase_delete(user, ids) do
    Activities.soft_delete_by(user, context: ids)
  end  

  # TODO ?
  defp publish(_flagger, _flagged, _flag, _community), do: :ok

  defp ap_publish(%Flag{creator_id: id}=flag), do: ap_publish(%{id: id}, flag)

  # defp ap_publish(user, %Flag{is_local: true} = flag) do
  #   FeedPublisher.publish(%{"context_id" => flag.id, "user_id" => user.id})
  # end

  defp ap_publish(_, _), do: :ok

  defp insert_activity(flagger, flag, verb) do
    Activities.create(flagger, flag, %{verb: verb, is_local: flag.is_local})
  end

  defp insert_flag(flagger, flagged, community, fields) do
    Repo.insert(Flag.create_changeset(flagger, community, flagged, fields))
  end

end
