defmodule Tag.TagThings do
  # import Ecto.Query
  # alias Ecto.Changeset
  alias MoodleNet.{
    # Common, GraphQL,
    Repo
  }

  alias Tag.Taggable

  def tag_things(user, tag, pointer_ids) when is_list(pointer_ids) do
    # requires a list of Pointer IDs
    with {:ok, pointers} <- MoodleNet.Meta.Pointers.many(ids: pointer_ids) do
      tag_pointers(user, tag, pointers)
    end
  end

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

  defp tag_pointers(user, %Taggable{} = tag, things) do
    Repo.transact_with(fn ->
      tag = Repo.preload(tag, :things)

      with {:ok, taggable} <- tag_pointers_save(tag, things) do
        taggable
      end
    end)
  end

  defp tag_pointers(_, "", _) do
    nil
  end

  defp tag_pointers(user, taggable, things) do
    with {:ok, tag} <- get_tag(taggable) do
      # with an existing tag
      tag_pointers(user, tag, things)
    else
      _e ->
        with tag <- maybe_make_taggable(user, taggable) do
          # with an object that we made taggable
          tag_pointers(user, tag, things)
        else
          _e ->
            {:error, "Could not find that tag or taggable context"}
        end
    end
  end

  def get_tag(id) do
    if MoodleNetWeb.Helpers.Common.is_numeric(id) do
      # try with taxonomyTag?
      # Taxonomy.TaxonomyTags.one(id: id)
      {:error, "not a ULID"}
    else
      # use Taggable
      Tag.Taggables.one(id: id)
    end
  end

  def maybe_make_taggable(user, %Taxonomy.TaxonomyTag{} = tt) do
    Taxonomy.TaxonomyTags.make_taggable(user, tt)
  end

  def maybe_make_taggable(user, future_taggable) do
    if MoodleNetWeb.Helpers.Common.is_numeric(future_taggable) do
      Taxonomy.TaxonomyTags.make_taggable(user, future_taggable)
    else
      Tag.Taggables.maybe_make_taggable(future_taggable)
    end
  end

  defp tag_pointers_save(tag, things) do
    IO.inspect(tag_pointers_insert: tag)
    IO.inspect(tag_pointers_insert: things)
    cs = Taggable.tag_things_changeset(tag, things)
    with {:ok, taggable} <- Repo.update(cs), do: {:ok, taggable}
  end
end
