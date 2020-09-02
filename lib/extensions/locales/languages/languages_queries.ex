# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Locales.Languages.Queries do
  import Ecto.Query

  alias CommonsPub.Locales.Language

  def query(Language) do
    from(u in Language, as: :language)
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
    where(q, [language: f], f.id == ^id)
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where(q, [language: f], f.id in ^ids)
  end

  ## by ordering

  def filter(q, {:order, :speakers}),
    do: order_by(q, [language: f], desc: f.speakers_native_total)
end
