# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Tag.Queries do
  import Ecto.Query

  alias Bonfire.Tag

  def query(Tag) do
    from(t in Tag,
      as: :tag,
      left_join: c in assoc(t, :character),
      as: :character
    )
  end

  def query(:count) do
    from(c in Tag, as: :tag)
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

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [tag: c], c.id == ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [tag: c], c.id in ^ids)

  def filter(q, {:username, username}) when is_binary(username) do
    where(q, [character: a], a.preferred_username == ^username)
  end

  def filter(q, {:username, usernames}) when is_list(usernames) do
    where(q, [character: a], a.preferred_username in ^usernames)
  end

  def filter(q, {:user, _user}), do: q

  # pagination

  def filter(q, {:limit, limit}), do: limit(q, ^limit)

  def filter(q, {:order, [asc: :id]}), do: order_by(q, [tag: r], asc: r.id)
  def filter(q, {:order, [desc: :id]}), do: order_by(q, [tag: r], desc: r.id)
end
