# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users do
  @doc """
  A "Context" for dealing with users, both local and remote
  """
  alias MoodleNet.Common
  alias MoodleNet.Repo
  alias MoodleNet.Actors
  alias MoodleNet.Actors.{Actor, ActorRevision}
  alias MoodleNet.Users.{User, UserFlag}
  alias MoodleNet.Meta
  alias Ecto.Changeset

  @doc """
  Registers a user:
  1. Splits attrs into actor and user fields
  2. Creates actor, user
  """
  @spec register(attrs :: map) :: {:ok, %User{}} | {:error, Changeset.t}
  def register(attrs) do
    Repo.transact_with(fn ->
      Meta.point_to!(User)
      |> User.register_changeset(attrs)
      |> Repo.insert()
    end)
  end

  @doc """
  Verify a user, allowing them to access their account and creating the relevant
  relations (i.e. Actors).
  """
  def verify(%User{} = user, attrs) do
    Repo.transact_with(fn ->
      with {:ok, user} <- Repo.update(User.confirm_email_changeset(user)),
           {:ok, actor} <- Actors.create_with_alias(user.id, attrs) do
        {:ok, user}
      end
    end)
  end

  def update() do
  end

  @doc """
  Flags a user with a given reason
  {:ok, UserFlag} | {:error, reason}
  """
  def flag(actor, user, attrs = %{reason: _}),
    do: Common.flag(UserFlag, :flag_user?, actor, user, attrs)

  @doc """
  Undoes a previous flag
  {:ok, UserFlag} | {:error, term()}
  """
  def undo_flag(actor, user), do: Common.undo_flag(UserFlag, actor, user)

  @doc """
  Lists all UserFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(UserFlag, :list_user_flags?, actor, filters)

  def communities_query(%User{id: them_id} = them, %User{} = me) do
    Communities.Members.list()
    |> Communities.Members.filter_query(them_id)
  end

  def preload_actor(%User{} = user, opts),
    do: Repo.preload(user, :actor, opts)

  defp extra_relation(%User{id: id}) when is_integer(id), do: :user

  defp preload_extra(%User{} = user, opts \\ []),
    do: Repo.preload(user, extra_relation(user), opts)
end
