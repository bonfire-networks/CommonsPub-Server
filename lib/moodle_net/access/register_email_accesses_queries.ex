# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailAccessesQueries do

  alias MoodleNet.Access.RegisterEmailAccess
  import Ecto.Query

  def query(RegisterEmailAccess), do: from(r in RegisterEmailAccess, as: :rea)

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(query, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [rea: r], r.id == ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [rea: r], r.id <= ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [rea: r], r.id >= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [rea: r], r.id in ^ids)

  def filter(q, {:email, email}) when is_binary(email), do: where(q, [rea: r], r.email == ^email)
  def filter(q, {:email, emails}) when is_list(emails), do: where(q, [rea: r], r.email in ^emails)


  def filter(q, {:page, [desc: [created: %{after: [id], limit: l}]]}) do
    filter(q, id: {:lte, id}, limit: l + 2, order: [desc: :created])
  end

  def filter(q, {:page, [desc: [created: %{before: [id], limit: l}]]}) do
    filter(q, id: {:gte, id}, limit: l + 2, order: [desc: :created])
  end

  def filter(q, {:page, [desc: [created: %{limit: l}]]}), do: filter(q, limit: l + 1, order: [desc: :created])


  def filter(q, {:order, [desc: :created]}), do: order_by(q, [rea: r], [desc: r.id])

  def filter(q, {:limit, limit}), do: limit(q, ^limit)

end
