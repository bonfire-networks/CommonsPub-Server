# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailAccessesQueries do

  alias MoodleNet.Access.RegisterEmailAccess
  import Ecto.Query

  def query(RegisterEmailAccess) do
    from r in RegisterEmailAccess, as: :register_email_access
  end

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [register_email_access: r], r.id == ^id
  end

  def filter(q, {:id, {:lte, id}}) when is_binary(id) do
    where q, [register_email_access: r], r.id <= ^id
  end

  def filter(q, {:id, {:gte, id}}) when is_binary(id) do
    where q, [register_email_access: r], r.id >= ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [register_email_access: r], r.id in ^ids
  end

  def filter(q, {:email, email}) when is_binary(email) do
    where q, [register_email_access: r], r.email == ^email
  end

  def filter(q, {:email, emails}) when is_list(emails) do
    where q, [register_email_access: r], r.email in ^emails
  end

  def filter(q, {:order, [desc: :created]}) do
    order_by q, [register_email_access: r], [desc: r.id]
  end

  def filter(q, {:limit, limit}) do
    limit(q, ^limit)
  end

  def filter(q, {:page, [desc: [created: %{after: [id], limit: l}]]}) do
    filter(q, id: {:lte, id}, limit: l + 2, order: [desc: :created])
  end

  def filter(q, {:page, [desc: [created: %{before: [id], limit: l}]]}) do
    filter(q, id: {:gte, id}, limit: l + 2, order: [desc: :created])
  end

  def filter(q, {:page, [desc: [created: %{limit: l}]]}) do
    filter(q, limit: l + 1, order: [desc: :created])
  end

end
