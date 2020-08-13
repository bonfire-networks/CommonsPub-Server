defmodule CommonsPub.Tag.Taggables do
  # import Ecto.Query
  alias Ecto.Changeset

  alias MoodleNet.{
    # Common,
    # GraphQL,
    Repo,
    GraphQL.Page,
    Common.Contexts
  }

  alias MoodleNet.Users.User
  alias CommonsPub.Tag.Taggable
  alias CommonsPub.Tag.Taggable.Queries

  alias Character.Characters

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  def one(filters), do: Repo.single(Queries.query(Taggable, filters))

  # def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Taggable, filters))}

  def prefix("Community") do
    "&"
  end

  def prefix("User") do
    "@"
  end

  def prefix(_) do
    "+"
  end

  ## mutations

  @doc """
  Create a Taggable that makes an existing object (eg. Geolocation) taggable
  """
  def maybe_make_taggable(user, id, _) when is_number(id) do
    with {:ok, t} <- maybe_taxonomy_tag(user, id) do
      {:ok, t}
    else
      _e ->
        {:error, "Please provider a pointer"}
    end
  end

  def maybe_make_taggable(user, pointer_id, attrs) when is_binary(pointer_id) do
    if MoodleNetWeb.Helpers.Common.is_numeric(pointer_id) do
      maybe_make_taggable(user, String.to_integer(pointer_id), attrs)
    else
      with {:ok, taggable} <- one(id: pointer_id) do
        {:ok, taggable}
      else
        _e ->
          with {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: pointer_id) do
            maybe_make_taggable(user, pointer, attrs)
          end
      end
    end
  end

  def maybe_make_taggable(user, %Pointers.Pointer{} = pointer, attrs) do
    with context = MoodleNet.Meta.Pointers.follow!(pointer) do
      maybe_make_taggable(user, context, attrs)
    end
  end

  def maybe_make_taggable(user, %{} = context, attrs) do
    with {:ok, taggable} <- one(id: context.id) do
      {:ok, taggable}
    else
      _e -> make_taggable(user, context, attrs)
    end
  end

  def maybe_make_taggable(user, context) do
    maybe_make_taggable(user, context, %{})
  end

  @doc """
  Create a taggable mixin for an existing poitable object (please use maybe_make_taggable instead)
  """
  defp make_taggable(creator, %{} = pointer_obj, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      # TODO: check that the taggable doesn't already exist (same name and parent)

      with {:ok, attrs} <- attrs_with_taggable(attrs, pointer_obj),
           {:ok, taggable} <- insert_taggable(attrs) do
        {:ok, taggable}
      end
    end)
  end

  defp attrs_with_taggable(%{facet: facet} = attrs, %{} = pointer_obj) when not is_nil(facet) do
    attrs = Map.put(attrs, :prefix, prefix(attrs.facet))
    attrs = Map.put(attrs, :id, pointer_obj.id)
    # IO.inspect(attrs)
    {:ok, attrs}
  end

  defp attrs_with_taggable(attrs, %{} = pointer_obj) do
    attrs_with_taggable(
      Map.put(
        attrs,
        :facet,
        pointer_obj.__struct__ |> to_string() |> String.split(".") |> List.last()
      ),
      pointer_obj
    )
  end

  defp insert_taggable(attrs) do
    IO.inspect(insert_taggable: attrs)
    cs = Taggable.create_changeset(attrs)
    with {:ok, taggable} <- Repo.insert(cs), do: {:ok, taggable}
  end

  # TODO: take the user who is performing the update
  def update(user, %Taggable{} = taggable, attrs) do
    Repo.transact_with(fn ->
      # :ok <- publish(taggable, :updated)
      with {:ok, taggable} <- Repo.update(Taggable.update_changeset(taggable, attrs)) do
        {:ok, taggable}
      end
    end)
  end

  # TODO move this common module
  @doc "conditionally update a map"
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)

  def maybe_taxonomy_tag(user, id) do
    if Code.ensure_loaded?(Taxonomy.TaxonomyTags) do
      Taxonomy.TaxonomyTags.maybe_make_category(user, id)
    end
  end
end
