defmodule Tag.TagThings do
  # import Ecto.Query
  # alias Ecto.Changeset
  alias MoodleNet.{
    # Common, GraphQL,
    Repo
  }

  # alias MoodleNet.Meta.{Pointer, Pointers, TableService}
  # alias MoodleNet.Users.User
  alias Tag.Taggable

  # alias Tag.Taggable.Queries
  # alias Character.Characters

  ## mutations

  def tag_thing_by_id(tag, pointer_id) do
    {:ok, pointer} = MoodleNet.Meta.Pointers.one(id: pointer_id)
    # things = MoodleNet.Meta.Pointers.follow!(pointer)
    tag_things(tag, [pointer])
  end

  def tag_things(%Taggable{} = tag, things) do
    Repo.transact_with(fn ->
      Repo.preload(tag, :things)

      with {:ok, r} <- tag_things_save(tag, things) do
        {:ok, r}
      end
    end)
  end

  def tag_things(tag_id, things) do
    {:ok, tag} = Tag.Taggables.get(tag_id)
    tag_things(tag, things)
  end

  defp tag_things_save(tag, things) do
    IO.inspect(tag_things_insert: tag)
    IO.inspect(tag_things_insert: things)
    cs = Taggable.tag_things_changeset(tag, things)
    with {:ok, _taggable} <- Repo.update(cs), do: {:ok, nil}
  end
end
