# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users do
  @doc """
  A "Context" for dealing with users, both local and remote
  """
  alias MoodleNet.Common
  alias MoodleNet.Repo
  alias MoodleNet.Actors.{Actor, ActorRevision}
  alias MoodleNet.Users.{User, UserFlag}
  alias MoodleNet.Meta

  @doc """
  Registers a user:
  1. Splits attrs into actor and user fields
  2. Creates actor, user
  """
  def register(attrs \\ %{}) do
    user_changeset = User.register_changeset(%User{}, attrs)

    user_keys =
      user_changeset.changes
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)

    pointer_changeset =
      Meta.TableService.lookup_id!("mn_user")
      |> Meta.Pointer.changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:pointer, pointer_changeset)
    |> Ecto.Multi.run(:user, fn repo, %{pointer: pointer} ->
      user_changeset
      |> Ecto.Changeset.put_change(:id, pointer.id)
      |> repo.insert()
    end)
    |> Ecto.Multi.run(:actor, fn _repo, %{user: user} ->
      actor_attrs = Map.drop(attrs, user_keys)
      MoodleNet.Actors.create(user.id, actor_attrs)
    end)
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
