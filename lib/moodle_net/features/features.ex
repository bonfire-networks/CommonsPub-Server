defmodule MoodleNet.Features do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.Features.Feature
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Users.User

  def featured_collections() do
    featured_collections_q()
    |> Repo.all()
    |> Query.unroll()
  end

  #todo counts

  def featured_communities() do
    featured_communities_q()
    |> Repo.all()
    |> Enum.map(fn {f,c,a} ->
      %{feature: f, community: c}
    end)
  end

  defp featured_collections_q() do
    from f in Feature,
      join: c in Collection,
      on: f.context_id == c.id,
      join: a in assoc(c, :actor),
      order_by: [desc: f.id],
      select: {f, c, a}
  end

  defp count_featured_collections_q() do
    from f in Feature,
      join: c in Collection,
      on: f.context_id == c.id,
      order_by: [desc: f.id],
      select: count(f)
  end

  defp featured_communities_q() do
    from f in Feature,
      join: c in Community,
      on: f.context_id == c.id,
      join: a in assoc(c, :actor),
      order_by: [desc: f.id],
      select: {f, c, a}
  end

  defp count_featured_communities_q() do
    from f in Feature,
      join: c in Community,
      on: f.context_id == c.id,
      order_by: [desc: f.id],
      select: count(f)
  end

end
