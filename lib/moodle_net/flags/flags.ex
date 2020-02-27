# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags do
  alias MoodleNet.{Activities, Common, Flags, Meta, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPages, NodesPage}
  alias MoodleNet.Flags.{AlreadyFlaggedError, Flag, NotFlaggableError, Queries}
  alias MoodleNet.Meta.{Pointer, Pointers, Table}
  alias MoodleNet.Users.{LocalUser, User}
  alias MoodleNet.Communities.Community
  import Ecto.Query

  def one(filters), do: Repo.single(Queries.query(Flag, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Flag, filters))}

  def nodes_page(cursor_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Flag, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, NodesPage.new(data, count, cursor_fn)}
    end
  end

  def edges(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, edges} = many(filters)
    {:ok, Edges.new(edges, group_fn)}
  end

  def edges_pages(group_fn, cursor_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  when is_function(group_fn, 1) and is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Flag, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, EdgesPages.new(data, count, group_fn, cursor_fn)}
    end
  end

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
        case one(creator_id: flagger.id, context_id: flagged.id) do
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
         {:ok, activity} <- insert_activity(flagger, flag, "created") do
      publish(flagger, flagged, flag, community, "created")
    end
  end

  # TODO: different for remote/local?
  defp publish(flagger, flagged, flag, community, verb) do
    {:ok, flag}
  end

  defp federate(%Flag{is_local: true} = flag), do: :ok
  defp federate(_), do: :ok

  defp insert_activity(flagger, flag, verb) do
    Activities.create(flagger, flag, %{verb: verb, is_local: flag.is_local})
  end

  defp insert_flag(flagger, flagged, community, fields) do
    Repo.insert(Flag.create_changeset(flagger, community, flagged, fields))
  end

  def resolve(%Flag{} = flag) do
    Repo.transact_with(fn ->
      with {:ok, flag} <- Common.soft_delete(flag),
        :ok <- federate(flag) do
        {:ok, flag}
      end
    end)
  end
end
