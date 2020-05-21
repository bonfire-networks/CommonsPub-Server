# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors do
  @doc """
  A Context for dealing with Actors.
  Actors come in several kinds:

  * Users
  * Communities
  * Collections
  """

  @replacement_regex ~r/[^a-zA-Z0-9-]/
  @wordsplit_regex ~r/[\t\n \_\|\(\)\#\@\.\,\;\[\]\/\\\}\{\=\*\&\<\>\:]/

  alias MoodleNet.Actors.{Actor, NameReservation, Queries}
  alias MoodleNet.Repo
  alias MoodleNet.Users.User
  alias Ecto.Changeset

  def one(filters), do: Repo.single(Queries.query(Actor, filters))

  @doc "true if the provided preferred_username is available to register"
  @spec is_username_available?(username :: binary) :: boolean()
  def is_username_available?(username) when is_binary(username) do
    is_nil(Repo.get(NameReservation, username))
  end

  @doc "Inserts a username reservation if it has not already been reserved"
  def reserve_username(username) when is_binary(username) do
    Repo.insert(NameReservation.changeset(username))
  end

  @doc "creates a new actor from the given attrs"
  @spec create(attrs :: map) :: {:ok, Actor.t()} | {:error, Changeset.t()}
  def create(attrs) when is_map(attrs) do
    # attrs = Map.put(attrs, :preferred_username, fix_preferred_username(Map.get(attrs, :preferred_username)))
    Repo.transact_with(fn ->
      with {:ok, actor} <- Repo.insert(Actor.create_changeset(attrs)) do
        if is_nil(actor.peer_id) do
          case reserve_username(attrs.preferred_username) do
            {:ok, _} -> {:ok, actor}
            _ -> {:error, "Username already taken"}
          end
        else
          {:ok, actor}
        end
      end
    end)
  end

  @spec update(user :: User.t(), actor :: Actor.t(), attrs :: map) :: {:ok, Actor.t()} | {:error, Changeset.t()}
  def update(%User{}, %Actor{} = actor, attrs) when is_map(attrs) do
    Repo.update(Actor.update_changeset(actor, attrs))
  end

  @spec delete(user :: User.t(), actor :: Actor.t()) :: {:ok, Actor.t()} | {:error, term}
  def delete(%User{}, %Actor{} = actor), do: Repo.delete(actor)

  def update_by(%User{}, filters, updates) do
    Repo.update_all(Queries.query(Actor, filters), set: updates)
  end

  def fix_preferred_username(username) when is_nil(username), do: nil

  def fix_preferred_username(username) do
    String.replace(
      String.replace(
        String.replace(username, @wordsplit_regex, "-"), 
      @replacement_regex, ""),
    ~r/--+/, "-")
  end

end
