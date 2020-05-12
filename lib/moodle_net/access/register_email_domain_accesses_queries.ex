# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailDomainAccessesQueries do

  alias MoodleNet.Access.RegisterEmailDomainAccess
  import Ecto.Query

  def query(RegisterEmailDomainAccess), do: from(r in RegisterEmailDomainAccess, as: :reda)

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [reda: r], r.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [reda: r], r.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [reda: r], r.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [reda: r], r.id in ^ids)

  def filter(q, {:domain, domain}) when is_binary(domain), do: where(q, [reda: r], r.domain == ^domain)
  def filter(q, {:domain, domains}) when is_list(domains), do: where(q, [reda: r], r.domain in ^domains)


  def filter(q, {:page, [desc: [created: %{after: [id], limit: l}]]}) do
    filter(q, id: {:lte, id}, limit: l + 2, order: [desc: :created])
  end

  def filter(q, {:page, [desc: [created: %{before: [id], limit: l}]]}) do
    filter(q, id: {:gte, id}, limit: l + 2, order: [desc: :created])
  end
  def filter(q, {:page, [desc: [created: %{limit: l}]]}), do: filter(q, limit: l + 1, order: [desc: :created])


  def filter(q, {:count, key}) when is_atom(key), do: select(q, [reda: r], {field(r, ^key), count(r.id)})

  def filter(q, {:limit, limit}), do: limit(q, ^limit)

  def filter(q, {:order, [desc: :created]}), do: order_by(q, [reda: r], [desc: r.id])

end
