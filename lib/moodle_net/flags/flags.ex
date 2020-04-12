# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags do
  alias MoodleNet.{Activities, Common, Repo}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.GraphQL.Fields
  alias MoodleNet.Flags.{AlreadyFlaggedError, Flag, NotFlaggableError, Queries}
  alias MoodleNet.Meta.{Pointers, Table}
  alias MoodleNet.Users.User

  def one(filters), do: Repo.single(Queries.query(Flag, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Flag, filters))}

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of flags according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.page Queries, Flag,
      cursor_fn, page_opts, base_filters, data_filters, count_filters
  end

  @doc """
  Retrieves a Pages of flags according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(group_fn, cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ []) do
    Contexts.pages_all Queries, Flag,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
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
        case one([:deleted, creator_id: flagger.id, context_id: flagged.id]) do
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
      federate(flag)
    end
  end

  # TODO: different for remote/local?
  defp publish(flagger, flagged, flag, community, verb) do
    {:ok, flag}
  end

  defp federate(%Flag{is_local: true} = flag) do
    :ok = MoodleNet.FeedPublisher.publish(%{
      "context_id" => flag.context_id,
      "user_id" => flag.creator_id,
                                          })
    {:ok, flag}
  end

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
