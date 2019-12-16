defmodule MoodleNet.Features do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.{Collections, Common, Communities, Repo}
  alias MoodleNet.Meta.TableService
  alias MoodleNet.Features.Feature
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Users.User

  def data(ctx) do
    Dataloader.Ecto.new Repo,
      query: &graphql_query/2,
      default_params: %{ctx: ctx}
  end

  def graphql_query(q, %{ctx: _}), do: q

  def fetch(id) when is_binary(id), do: Repo.single(fetch_q(id))

  defp fetch_q(id) do
    from f in Feature,
      join: c in assoc(f, :context),
      where: is_nil(f.deleted_at),
      order_by: [desc: f.id],
      select: f,
      preload: [context: c]
  end

  def list(opts \\ %{}) do
    Repo.all(list_q(opts))
  end

  def count_for_list(opts \\ %{}) do
    Repo.one(count_for_list_q(opts))
  end

  def create(%User{}=creator, context, attrs) do
    Feature.create_changeset(creator, context, attrs)
    |> Repo.insert()
  end

  def create(_, _, _), do: GraphQL.not_permitted()

  @default_feature_contexts [Collection, Community]
  def list_q(opts \\ %{}) do
    table_ids =
      Map.get(opts, :contexts, @default_feature_contexts)
      |> Enum.map(&TableService.lookup_id!/1)
    from f in Feature,
      join: c in assoc(f, :context),
      where: is_nil(f.deleted_at),
      where: c.table_id in ^table_ids,
      order_by: [desc: f.id],
      select: f,
      preload: [context: c]
  end
  
  def count_for_list_q(opts \\ %{}) do
    table_ids =
      Map.get(opts, :contexts, @default_feature_contexts)
      |> Enum.map(&TableService.lookup_id!/1)
    from f in Feature,
      join: c in assoc(f, :context),
      where: is_nil(f.deleted_at),
      where: c.table_id in ^table_ids,
      select: count(f)
  end

  def delete(%Feature{}=feat), do: Common.soft_delete(feat)

end
