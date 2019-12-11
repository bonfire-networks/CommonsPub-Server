# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags do
  alias MoodleNet.{Activities, Common, Feeds, Repo}
  alias MoodleNet.Flags.{AlreadyFlaggedError, Flag, NotFlaggableError}
  alias MoodleNet.Users.User
  alias MoodleNet.Communities.Community
  import Ecto.Query
  

  def fetch(id), do: Repo.single(fetch_q(id))

  defp fetch_q(id) do
    from f in Flag,
      where: is_nil(f.deleted_at),
      where: f.id == ^id
  end

  def find(%User{} = flagger, flagged), do: Repo.single(find_q(flagger.id, flagged.id))

  defp find_q(flagger_id, flagged_id) do
    from(f in Flag,
      where: f.creator_id == ^flagger_id,
      where: f.context_id == ^flagged_id,
      where: is_nil(f.deleted_at)
    )
  end

  def create(
    %User{} = flagger,
    flagged,
    community \\ nil,
    %{is_local: is_local} = fields
  ) when is_boolean(is_local) do
    Repo.transact_with(fn ->
      case find(flagger, flagged) do
        {:ok, _} -> {:error, AlreadyFlaggedError.new(flagged.id)}
        _ -> really_create(flagger, flagged, community, fields)
      end
    end)
  end

  defp really_create(flagger, flagged, community, fields) do
    with {:ok, flag} <- insert_flag(flagger, flagged, community, fields),
         {:ok, activity} <- insert_activity(flagger, flag, "create") do
      publish(flagger, flagged, flag, community, "create")
    end
  end
    
  # TODO: different for remote/local?
  defp publish(flagger, flagged, flag, community, verb) do
    {:ok, flag}
  end

  defp insert_activity(flagger, flag, verb) do
    Activities.create(flagger, flag, %{verb: verb, is_local: flag.is_local})
  end

  defp insert_flag(flagger, flagged, community, fields) do
    Repo.insert(Flag.create_changeset(flagger, community, flagged, fields))
  end

  def resolve(%Flag{} = flag) do
    Repo.transact_with(fn -> Common.soft_delete(flag) end)
  end

  @doc """
  Return a list of open flags for an user.
  """
  def list_by(%User{} = user), do: Repo.all(list_by_query(user))

  @doc """
  Return a list of open flags for any object participating in the meta abstraction.
  """
  def list_of(%{id: _id} = thing), do: Repo.all(list_of_query(thing))

  @doc """

  Return open flags in a community.
  """
  def list_in_community(%Community{id: id}) do
    Repo.all(list_in_community_query(id))
  end

  defp list_in_community_query(id) do
    from(f in Flag,
      where: is_nil(f.deleted_at),
      where: f.community_id == ^id
    )
  end

  defp list_by_query(%User{id: id}) do
    from(f in Flag,
      where: is_nil(f.deleted_at),
      where: f.creator_id == ^id
    )
  end

  defp list_of_query(%{id: id}) do
    from(f in Flag,
      where: is_nil(f.deleted_at),
      where: f.context_id == ^id
    )
  end

end
