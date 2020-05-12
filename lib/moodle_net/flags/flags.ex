# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags do
  alias MoodleNet.{Activities, Common, Repo}
  alias MoodleNet.Flags.{AlreadyFlaggedError, Flag, NotFlaggableError, Queries}
  alias MoodleNet.Meta.{Pointers, Table}
  alias MoodleNet.Users.User
  alias MoodleNet.Workers.APPublishWorker

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
         :ok <- publish(flagger, flagged, flag, community, :created),
         :ok <- ap_publish("create", flag) do
      {:ok, flag}
    end
  end

  # TODO ?
  defp publish(_flagger, _flagged, _flag, _community, :created), do: :ok

  defp ap_publish(verb, %Flag{is_local: true} = flag) do
    APPublishWorker.enqueue(verb, %{"context_id" => flag.id})
    :ok
  end

  defp ap_publish(_, _), do: :ok

  defp insert_activity(flagger, flag, verb) do
    Activities.create(flagger, flag, %{verb: verb, is_local: flag.is_local})
  end

  defp insert_flag(flagger, flagged, community, fields) do
    Repo.insert(Flag.create_changeset(flagger, community, flagged, fields))
  end

  def soft_delete(%Flag{} = flag) do
    Repo.transact_with(fn ->
      with {:ok, flag} <- Common.soft_delete(flag),
           :ok <- ap_publish("delete", flag) do
        {:ok, flag}
      end
    end)
  end

  def update_by(filters, updates), do: Repo.update_all(Queries.query(Flag, filters), updates)

end
