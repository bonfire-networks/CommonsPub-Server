# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Tag.Taggable.Queries do
  import Ecto.Query

  alias Tag.Taggable

  def query(Taggable) do
    from(t in Taggable,
      as: :tag,
      left_join: p in assoc(t, :profile),
      as: :profile,
      left_join: c in assoc(t, :character),
      as: :character,
      left_join: pt in assoc(t, :parent_tag),
      as: :parent_tag,
      select_merge: %{name: p.name},
      select_merge: %{summary: p.summary}
    )
  end

  def query(:count) do
    from(c in Taggable, as: :tag)
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

  def filter(q, {:id, id}) when is_binary(id) do
    where(q, [tag: f], f.id == ^id)
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where(q, [tag: f], f.id in ^ids)
  end

  def filter(q, {:taxonomy_tag_id, id}) when is_integer(id) do
    where(q, [tag: f], f.taxonomy_tag_id == ^id)
  end

  def filter(q, {:taxonomy_tag_id, ids}) when is_list(ids) do
    where(q, [tag: f], f.taxonomy_tag_id in ^ids)
  end

  def filter(q, {:name, name}) when is_binary(name) do
    where(q, [tag: f, profile: p], f.name == ^name)
  end

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [tag: c], c.id == ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [tag: c], c.id in ^ids)

  # get children of tag
  def filter(q, {:parent_tag, id}) when is_binary(id),
    do: where(q, [tag: t], t.parent_tag_id == ^id)

  def filter(q, {:parent_tag, ids}) when is_list(ids),
    do: where(q, [tag: t], t.parent_tag_id in ^ids)

  # get children with character
  def filter(q, {:context, id}) when is_binary(id),
    do: where(q, [tag: t, character: c], c.context_id == ^id)

  def filter(q, {:context, ids}) when is_list(ids),
    do: where(q, [tag: t, character: c], c.context_id in ^ids)

  # join with character
  def filter(q, :default) do
    filter(q, preload: :profile, preload: :character, preload: :parent_tag)
  end

  def filter(q, {:preload, :profile}) do
    preload(q, [profile: p], profile: p)
  end

  def filter(q, {:preload, :character}) do
    preload(q, [character: c], character: c)
  end

  def filter(q, {:preload, :parent_tag}) do
    preload(q, [parent_tag: pt], parent_tag: pt)
  end

  def filter(q, {:user, _user}), do: q

  # pagination

  def filter(q, {:limit, limit}), do: limit(q, ^limit)

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
