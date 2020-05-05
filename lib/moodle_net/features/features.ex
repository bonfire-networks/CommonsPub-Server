defmodule MoodleNet.Features do
  alias MoodleNet.{Common, Features, GraphQL, Repo}
  alias MoodleNet.Common.Contexts
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

  def soft_delete(%Feature{} = feature), do: Common.soft_delete(feature)

  defp get_valid_contexts() do
    Application.fetch_env!(:moodle_net, Features)
    |> Keyword.fetch!(:valid_contexts)
  end

end
