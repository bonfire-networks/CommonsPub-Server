# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Fake do
  @moduledoc """
  A library of functions that generate fake data suitable for tests
  """
  @doc """
  Reruns a faker until a predicate passes.
  Default limit is 10 tries.
  """
  def such_that(faker, name, test, limit \\ 10)

  def such_that(faker, name, test, limit)
      when is_integer(limit) and limit > 0 do
    fake = faker.()

    if test.(fake),
      do: fake,
      else: such_that(faker, name, test, limit - 1)
  end

  def such_that(_faker, name, _test, _limit) do
    throw({:tries_exceeded, name})
  end

  @doc """
  Reruns a faker until an unseen value has been generated.
  Default limit is 10 tries.
  Stores seen things in the process dict (yes, *that* process dict)
  """
  def unused(faker, name, limit \\ 10)
  def unused(_faker, name, 0), do: throw({:error, {:tries_exceeded, name}})

  def unused(faker, name, limit) when is_integer(limit) do
    used = get_used(name)
    fake = such_that(faker, name, &(&1 not in used))
    forbid(name, [fake])
    fake
  end

  @doc """
  Partner to `unused`. Adds a list of values to the list of used
  values under a key.
  """
  def forbid(name, values) when is_list(values) do
    set_used(name, values ++ get_used(name))
  end

  @doc """
  Returns the next unused integer id for `name` starting from `start`.
  Permits jumping by artificially increasing start - if start is
  higher than the last used id, it will return start and set it as the
  last used id
  """
  def sequential(name, start) when is_integer(start) do
    val = nextval(get_seq(name, start - 1), start)
    set_seq(name, val)
    val
  end

  # Basic data

  @doc "Generates a random boolean"
  def bool(), do: Faker.Util.pick([true, false])
  @doc "Generates a random unique uuid"
  def uuid(), do: unused(&Faker.UUID.v4/0, :uuid)
  @doc "Generates a random unique email"
  def email(), do: unused(&Faker.Internet.email/0, :email)
  @doc "Generates a random unique okta id"
  def okta_id(), do: unused(fn -> String.upcase(Faker.App.name()) end, :okta_id)
  @doc "Generates a random date of birth based on an age range of 18-99"
  def date_of_birth(), do: Faker.Date.date_of_birth(18..99)
  @doc "Picks a date up to 300 days in the past, not including today"
  def past_date(), do: Faker.Date.backward(300)
  @doc "Picks a date up to 300 days in the future, not including today"
  def future_date(), do: Faker.Date.forward(300)
  @doc "Picks a datetime up to 300 days in the future, not including today"
  def future_datetime(), do: Faker.DateTime.forward(300)
  @doc "Picks a random gender from a (woefully short) list"
  def gender(), do: Faker.Util.pick(["Male", "Female", "Other", "Prefer not to say"])
  @doc "Picks a random role for a user tenant"
  def role(), do: Faker.Util.pick(["staff", "call_center", "call_center_readonly"])

  
  # def user()
  # def community(owner)
  # def collection(community)
  # def

  # Support for `unused/3`

  @doc false
  def used_key(name), do: {__MODULE__, {:used, name}}
  @doc false
  def get_used(name), do: Process.get(used_key(name), [])
  @doc false
  def set_used(name, used) when is_list(used), do: Process.put(used_key(name), used)

  # support for `sequential/2`

  defp nextval(id, start)
  defp nextval(nil, start), do: start
  defp nextval(id, start) when id < start, do: start
  defp nextval(id, _), do: id + 1

  defp seq_key(name), do: {__MODULE__, {:seq, name}}
  defp get_seq(name, default), do: Process.get(seq_key(name), default)
  defp set_seq(name, seq) when is_integer(seq), do: Process.put(seq_key(name), seq)

end
