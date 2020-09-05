# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Tag.Category.Queries do
  import Ecto.Query

  alias CommonsPub.Tag.Category
  import CommonsPub.Common.Query, only: [match_admin: 0]

  def query(Category) do
    from(t in Category,
      as: :category,
      left_join: tg in assoc(t, :taggable),
      as: :taggable,
      left_join: p in assoc(t, :profile),
      as: :profile,
      left_join: c in assoc(t, :character),
      as: :character,
      left_join: pt in assoc(t, :parent_category),
      as: :parent_category,
      select_merge: %{name: p.name},
      select_merge: %{summary: p.summary},
      select_merge: %{prefix: tg.prefix},
      select_merge: %{facet: tg.facet}
      # select_merge: %{preferred_username: c.preferred_username},
      # select_merge: %{canonical_url: c.canonical_url}
    )
  end

  def query(:count) do
    from(c in Category, as: :category)
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
    where(q, [category: f], f.id == ^id)
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where(q, [category: f], f.id in ^ids)
  end

  def filter(q, {:username, username}) when is_binary(username) do
    where(q, [character: a], a.preferred_username == ^username)
  end

  def filter(q, {:username, usernames}) when is_list(usernames) do
    where(q, [character: a], a.preferred_username in ^usernames)
  end

  def filter(q, {:name, name}) when is_binary(name) do
    where(q, [category: f, profile: p], f.name == ^name)
  end

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [category: c], c.id == ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [category: c], c.id in ^ids)

  # get children of category
  def filter(q, {:parent_category, id}) when is_binary(id),
    do: where(q, [category: t], t.parent_category_id == ^id)

  def filter(q, {:parent_category, ids}) when is_list(ids),
    do: where(q, [category: t], t.parent_category_id in ^ids)

  # get with character
  def filter(q, {:caretaker, id}) when is_binary(id),
    do: where(q, [category: t], t.caretaker_id == ^id)

  def filter(q, {:caretaker, ids}) when is_list(ids),
    do: where(q, [category: t], t.caretaker_id in ^ids)

  def filter(q, :toplevel) do
    top_level_category = System.get_env("TOP_LEVEL_CATEGORY", "")

    if !is_nil(top_level_category) and top_level_category != "" do
      where(q, [category: t], t.parent_category_id == ^top_level_category)
    else
      where(q, [category: t], is_nil(t.parent_category_id))
    end
  end

  def filter(q, :default) do
    filter(
      q,
      [
        :deleted,
        preload: :taggable,
        preload: :profile,
        preload: :character,
        preload: :parent_category
      ]
    )
  end

  def filter(q, {:preload, :taggable}) do
    preload(q, [taggable: p], taggable: p)
  end

  def filter(q, {:preload, :profile}) do
    preload(q, [profile: p], profile: p)
  end

  def filter(q, {:preload, :character}) do
    preload(q, [character: c], character: c)
  end

  def filter(q, {:preload, :parent_category}) do
    preload(q, [parent_category: pt], parent_category: pt)
  end

  # def filter(q, {:user, _user}), do: q

  def filter(q, {:user, match_admin()}), do: q

  # def filter(q, {:user, %User{id: id} = user}) do
  #   q
  #   |> join_to(follow: id)
  #   |> where([category: o, follow: f], not is_nil(o.published_at) or not is_nil(f.id))
  # end

  def filter(q, {:user, %{id: _id} = _user}) do
    q
    |> where([category: o], not is_nil(o.published_at))
  end

  def filter(q, {:user, nil}) do
    filter(q, ~w(deleted disabled private)a)
  end

  ## by status

  def filter(q, :deleted) do
    where(q, [category: o], is_nil(o.deleted_at))
  end

  def filter(q, :disabled) do
    where(q, [category: o], is_nil(o.disabled_at))
  end

  def filter(q, :private) do
    where(q, [category: o], not is_nil(o.published_at))
  end

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

  def filter(q, {:order, [asc: :id]}), do: order_by(q, [category: r], asc: r.id)
  def filter(q, {:order, [desc: :id]}), do: order_by(q, [category: r], desc: r.id)
end
