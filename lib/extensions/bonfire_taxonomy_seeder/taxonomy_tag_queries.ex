# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.TaxonomySeeder.TaxonomyTag.Queries do
  import Ecto.Query

  alias Bonfire.TaxonomySeeder.TaxonomyTag

  def query(TaxonomyTag) do
    from(t in TaxonomyTag,
      as: :tag,
      left_join: pt in assoc(t, :parent_tag),
      as: :parent_tag,
      left_join: c in assoc(t, :category),
      as: :category
    )
  end

  def query(:count) do
    from(c in TaxonomyTag, as: :tag)
  end

  def query(q, filters), do: filter(query(q), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  def join_to(q, table_or_tables, jq \\ :left)

  ## many

  def join_to(q, tables, jq) when is_list(tables) do
    Enum.reduce(tables, q, &join_to(&2, &1, jq))
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by join

  def filter(q, {:join, {rel, jq}}), do: join_to(q, rel, jq)

  def filter(q, {:join, rel}), do: join_to(q, rel)

  ## by field values

  def filter(q, {:id, id}) when is_integer(id) do
    where(q, [tag: f], f.id == ^id)
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where(q, [tag: f], f.id in ^ids)
  end

  def filter(q, {:id, id}) when is_binary(id) do
    where(q, [tag: f], f.id == ^id)
  end

  def filter(q, {:category_id, ids}) when is_list(ids) do
    where(q, [tag: f], f.category_id in ^ids)
  end

  def filter(q, {:category_id, id}) when is_binary(id) do
    where(q, [tag: f], f.category_id == ^id)
  end

  def filter(q, {:name, name}) when is_binary(name) do
    where(q, [tag: f], f.name == ^name)
  end

  # get children in taxonomy
  def filter(q, {:parent_tag, id}) when is_integer(id),
    do: where(q, [tag: t], t.parent_tag_id == ^id)

  def filter(q, {:parent_tag, ids}) when is_list(ids),
    do: where(q, [tag: t], t.parent_tag_id in ^ids)

  def filter(q, :default) do
    filter(q, preload: :parent_tag, preload: :category)
  end

  def filter(q, {:filter, :default}) do
    filter(q, :default)
  end

  def filter(q, {:preload, :category}) do
    preload(q, [category: tg], category: tg)
  end

  def filter(q, {:preload, :parent_tag}) do
    preload(q, [parent_tag: pt], parent_tag: pt)
  end

  def filter(q, {:limit, limit}), do: limit(q, ^limit)

  def filter(q, {:user, _user}), do: q

  # pagination

  def filter(q, {:page, [desc: [id: %{after: [id], limit: limit}]]}) do
    filter(q, order: [desc: :id], id: {:lte, id}, limit: limit + 2)
  end

  def filter(q, {:page, [desc: [id: %{before: [id], limit: limit}]]}) do
    filter(q, order: [desc: :id], id: {:gte, id}, limit: limit + 2)
  end

  def filter(q, {:page, [desc: [id: %{limit: limit}]]}) do
    filter(q, order: [desc: :id], limit: limit + 1)
  end

  def filter(q, {:page, [asc: [id: %{after: [id], limit: limit}]]}) do
    filter(q, order: [asc: :id], id: {:gte, id}, limit: limit + 2)
  end

  def filter(q, {:page, [asc: [id: %{before: [id], limit: limit}]]}) do
    filter(q, order: [asc: :id], id: {:lte, id}, limit: limit + 2)
  end

  def filter(q, {:page, [asc: [id: %{limit: limit}]]}) do
    filter(q, order: [asc: :id], limit: limit + 1)
  end

  def filter(q, {:order, [asc: :id]}), do: order_by(q, [tag: r], asc: r.id)
  def filter(q, {:order, [desc: :id]}), do: order_by(q, [tag: r], desc: r.id)
end
