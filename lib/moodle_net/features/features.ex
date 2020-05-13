# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Features do
  alias MoodleNet.{Activities, Common, Features, GraphQL, Repo}
  alias MoodleNet.Features.{Feature, Queries}
  alias MoodleNet.Meta.{Pointer, Pointers}
  alias MoodleNet.Users.User

  def one(filters), do: Repo.single(Queries.query(Feature, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Feature, filters))}

  def create(%User{}=creator, %Pointer{}=context, attrs) do
    target_table = Pointers.table!(context)
    if target_table.schema in get_valid_contexts() do
      Repo.insert(Feature.create_changeset(creator, context, attrs))
    else
      {:error, GraphQL.not_permitted()}
    end
  end

  def create(%User{}=creator, %struct{}=context, attrs) do
    if struct in get_valid_contexts() do
      Repo.insert(Feature.create_changeset(creator, context, attrs))
    else
      {:error, GraphQL.not_permitted()}
    end
  end

  def update_by(%User{}, filters, updates) do
    Repo.update_all(Queries.query(Feature, filters), set: updates)
  end

  def soft_delete(%User{}=user, %Feature{} = feature) do
    Repo.transact_with(fn ->
      with {:ok, feature} <- Common.soft_delete(feature),
           :ok <- chase_delete(user, feature.id) do
           # :ok <- ap_publish(feature) do
        {:ok, feature}
      end      
    end)
  end

  def soft_delete_by(%User{}=user, filters) do
    with {:ok, _} <-
      Repo.transact_with(fn ->
        {_, ids} = update_by(user, [{:deleted, false}, {:select, :id} | filters], deleted_at: DateTime.utc_now())
        chase_delete(user, ids)
      end), do: :ok
  end

  defp chase_delete(user, ids) do
    Activities.soft_delete_by(user, context: ids)
  end  
  
  defp get_valid_contexts() do
    Application.fetch_env!(:moodle_net, Features)
    |> Keyword.fetch!(:valid_contexts)
  end

  # defp ap_publish(_), do: :ok

end
