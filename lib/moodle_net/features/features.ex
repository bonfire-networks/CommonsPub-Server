defmodule MoodleNet.Features do
  import ProtocolEx
  alias MoodleNet.{Common, Features, GraphQL, Repo}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Features.{Feature, Queries}
  alias MoodleNet.Meta.{Pointable, Pointer, Pointers}
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

  def create(%User{}=creator, %{__struct__: struct}=context, attrs) do
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

  defimpl_ex FeaturePointable, Feature, for: Pointable do
    def queries_module(_), do: Queries
  end

end
