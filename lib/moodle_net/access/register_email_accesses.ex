# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailAccesses do

  alias MoodleNet.Repo
  alias MoodleNet.Access.{RegisterEmailAccess, RegisterEmailAccessesQueries}
  alias MoodleNet.Batching.EdgesPage

  def one(filters) do
    Repo.single(RegisterEmailAccessesQueries.query(RegisterEmailAccess, filters))
  end

  def many(filters \\ []) do
    {:ok, Repo.all(RegisterEmailAccessesQueries.query(RegisterEmailAccess, filters))}
  end

  def create(email) do
    Repo.insert(RegisterEmailAccess.create_changeset(%{email: email}))
  end
  
end
