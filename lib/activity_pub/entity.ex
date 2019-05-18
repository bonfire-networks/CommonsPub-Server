defmodule ActivityPub.Entity do
  @moduledoc """

`Entity` is used to refer to any ActivityPub `Object` or `Link` in the library—ActivityPub `Object` and `Link` are disjoint, they are different things. An AP `Entity` is just a map which also has the field `__ap__` set to a `ActivityPub.Metadata` struct.

**Note:** Elixir Structs couldn't be used because they have fixed fields, which would produce compilation errors in case of unknown properties.

In addition to the `ActivityPub.Metadata` struct in the `__ap__` field, the map it also stores every property it has, like in JSON. This allows working with the `Entity` in simple ways:
- actor.followers
- actor[:followers]
  """

  require ActivityPub.Guards, as: APG

  alias ActivityPub.{Metadata}

  # FIXME Inject here the builder with a list of aspects (and a list of types)?

  def aspects(entity = %{__ap__: meta}) when APG.is_entity(entity),
    do: Metadata.aspects(meta)

  def fields_for(entity, aspect) when APG.has_aspect(entity, aspect) do
    Map.take(entity, aspect.__aspect__(:fields))
  end

  def fields_for(_, _), do: %{}

  def fields(entity) when APG.is_entity(entity) do
    entity
    |> aspects()
    |> Enum.flat_map(&fields_for(entity, &1))
  end

  def assocs_for(entity, aspect) when APG.has_aspect(entity, aspect),
    do: Map.take(entity, aspect.__aspect__(:associations))

  def assocs_for(_, _), do: %{}

  def assocs(e) when APG.is_entity(e) do
    e
    |> aspects()
    |> Enum.reduce(%{}, fn aspect, acc ->
      Map.take(e, aspect.__aspect__(:associations))
      |> Map.merge(acc)
    end)
  end

  @doc """
  If the entity uses any properties that aren't part of ActivityStreams' [standard vocabulary](https://www.w3.org/TR/activitystreams-vocabulary/), but are instead used as [extensions](https://www.w3.org/TR/activitystreams-core/#extensibility) to the vocabulary (MoodleNet-specific ones or otherwise), those are stored using strings instead of atoms: `actor["extension_field"]`

  There are two reasons:
  1. We have a clear difference between extension fields and regular fields defined by an _aspect_.
  2. We avoid the "atom overload" attack—the BEAM Garbage Collector doesn't collect atoms.
  """
  def extension_fields(entity) when APG.is_entity(entity) do
    Enum.reduce(entity, %{}, fn
      {key, _}, acc when is_atom(key) -> acc
      {key, value}, acc when is_binary(key) -> Map.put(acc, key, value)
    end)
  end

  def local?(%{__ap__: ap} = e) when APG.is_entity(e), do: Metadata.local?(ap)

  def status(%{__ap__: %{status: status}} = e) when APG.is_entity(e), do: status

  def local_id(%{__ap__: meta} = e) when APG.is_entity(e), do: Metadata.local_id(meta)

  def persistence(%{__ap__: %{persistence: persistence}} = e) when APG.is_entity(e), do: persistence
end
