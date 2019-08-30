# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users do
  @doc """
  A "Context" for dealing with users, both local and remote
  """
  alias MoodleNet.Common
  alias MoodleNet.Users.UserFlag

  @doc """
  Registers a local user:
  1. Splits attrs into actor and user fields
  2. Creates actor, user and localuser
  """
  def register_local(attrs \\ %{}) do
  end

  def create_remote(attrs \\ %{}) do
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
  def flag(actor, user, attrs=%{reason: _}),
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

  def communities_query(%User{id: them_id}=them, %User{}=me) do
    Communities.Members.list()
    |> Communities.Members.filter_query(them_id)
  end
  
  def preload_actor(%User{}=user, opts),
    do: Repo.preload(user, :actor, opts)

  defp extra_relation(%User{local_user_id: id}) when is_integer(id), do: :local_user
  defp extra_relation(%User{remote_user_id: id}) when is_integer(id), do: :remote_user

  defp preload_extra(%User{}=user, opts \\ []),
    do: Repo.preload(user, extra_relation(user), opts)

end
