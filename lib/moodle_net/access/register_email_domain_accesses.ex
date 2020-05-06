# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailDomainAccesses do

  alias MoodleNet.{Common, Repo}
  alias MoodleNet.Access.{RegisterEmailDomainAccess, RegisterEmailDomainAccessesQueries}

  def one(filters) do
    RegisterEmailDomainAccessesQueries.query(RegisterEmailDomainAccess, filters)
    |> Repo.single()
  end

  def many(filters \\ []) do
    query = RegisterEmailDomainAccessesQueries.query(RegisterEmailDomainAccess, filters)
    {:ok, Repo.all(query)}
  end

  def create(domain) do
    changeset = RegisterEmailDomainAccess.create_changeset(%{domain: domain})
    with {:error, _changeset} <- Repo.insert(changeset),
      do: {:error, "Domain already allowlisted"}
  end
  
  def soft_delete(%RegisterEmailDomainAccess{}=it), do: Common.soft_delete(it)

end
