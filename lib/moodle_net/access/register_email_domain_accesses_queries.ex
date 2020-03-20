# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailDomainAccessesQueries do

  alias MoodleNet.Access.RegisterEmailDomainAccess
  import Ecto.Query

  def query(RegisterEmailDomainAccess) do
    from r in RegisterEmailDomainAccess, as: :register_email_domain_access
  end

  def query(query, filters), do: filter(query(query), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [register_email_domain_access: r], r.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [register_email_domain_access: r], r.id in ^ids
  end

  def filter(q, {:email, email}) when is_binary(email) do
    where q, [register_email_domain_access: r], r.email == ^email
  end

  def filter(q, {:email, emails}) when is_list(emails) do
    where q, [register_email_domain_access: r], r.email in ^emails
  end

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [register_email_domain_access: r], [desc: r.id]
  end

end
