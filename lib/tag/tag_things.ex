defmodule CommonsPub.Tag.TagThings do
  # import Ecto.Query
  # alias Ecto.Changeset
  alias MoodleNet.{
    # Common, GraphQL,
    Repo
  }

  alias CommonsPub.Tag.Taggable

  def tag_thing(user, tag, pointer_id) when is_binary(pointer_id) do
    with {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: pointer_id) do
      # thing = MoodleNet.Meta.Pointers.follow!(pointer)
      tag_pointers(user, tag, [pointer])
    end
  end

  def tag_thing(user, tag, %Pointers.Pointer{} = pointer) do
    tag_pointers(user, tag, [pointer])
  end

  def tag_thing(user, tag, %{id: id}) do
    tag_thing(user, tag, id)
  end

  def tag_things(user, tag, pointer_ids) when is_list(pointer_ids) do
    # requires a list of Pointer IDs
    with {:ok, pointers} <- MoodleNet.Meta.Pointers.many(ids: pointer_ids) do
      tag_pointers(user, tag, pointers)
    end
  end

  defp tag_pointers(user, %Taggable{} = tag, things) do
    Repo.transact_with(fn ->
      tag = Repo.preload(tag, :things)

      with {:ok, taggable} <- tag_pointers_save(tag, things) do
        {:ok, taggable}
      end
    end)
  end

  defp tag_pointers(_, "", _) do
    nil
  end

  defp tag_pointers(user, {:error, e}, things) do
    IO.inspect(invalid_taggable: e)
    nil
  end

  defp tag_pointers(user, taggable, things) do
    IO.inspect(taggable)
    IO.inspect(things)

    with {:ok, tag} <- CommonsPub.Tag.Taggables.maybe_make_taggable(user, taggable) do
      IO.inspect(taggable)
      # with an object that we made taggable
      tag_pointers(user, tag, things)
    else
      _e ->
        {:error, "Could not find or create such a tag or taggable context"}
    end
  end

  defp tag_pointers_save(tag, things) do
    IO.inspect(tag_pointers_insert: tag)
    IO.inspect(tag_pointers_insert: things)
    cs = Taggable.tag_things_changeset(tag, things)
    with {:ok, taggable} <- Repo.update(cs), do: {:ok, taggable}
  end
end
