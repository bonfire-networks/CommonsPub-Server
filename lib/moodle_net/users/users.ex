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

  @doc """
  Registers a user:
  1. Splits attrs into actor and user fields
  2. Creates actor, user
  """
  def register(multi \\ Multi.new(), attrs \\ %{}) do
    multi
    |> Ecto.Multi.insert(:pointer, Meta.pointer_changeset(User))
    |> Ecto.Multi.run(:user, fn repo, %{pointer: pointer} ->
      %User{}
      |> User.register_changeset(attrs)
      |> Ecto.Changeset.put_change(:id, pointer.id)
      |> repo.insert()
    end)
    |> Actors.create(attrs)
    |> Repo.transaction()
  end

  @doc """
  Update a User, RemoteUser or LocalUser
  """
  def update(user, changes) do
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
