# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

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

  @type t :: Map.t()

  @doc """
  Return all aspects for an entity.
  """
  @spec aspects(t) :: [atom]
  def aspects(entity = %{__ap__: meta}) when APG.is_entity(entity),
    do: Metadata.aspects(meta)

  @doc """
  Return all fields used by an entity with the given aspect.
  """
  @spec fields_for(t, atom) :: Map.t()
  def fields_for(entity, aspect) when APG.has_aspect(entity, aspect) do
    Map.take(entity, aspect.__aspect__(:fields))
  end

  def fields_for(_, _), do: %{}

  @doc """
  Return all fields, for all aspects, of an entity.
  """
  @spec fields(t) :: [Map.t()]
  def fields(entity) when APG.is_entity(entity) do
    entity
    |> aspects()
    |> Enum.flat_map(&fields_for(entity, &1))
  end

  @doc """
  Return all associations used by an entity with the given aspect.
  """
  @spec assocs_for(t, atom) :: Map.t()
  def assocs_for(entity, aspect) when APG.has_aspect(entity, aspect),
    do: Map.take(entity, aspect.__aspect__(:associations))

  def assocs_for(_, _), do: %{}

  @doc """
  Return all associations, for all aspects, of an entity.

  This is returned as a map, all conflicting associations are merged using the
  standard `Map.merge/2`.
  """
  @spec assocs(t) :: Map.t()
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
  @spec extension_fields(t) :: Map.t()
  def extension_fields(entity) when APG.is_entity(entity) do
    Enum.reduce(entity, %{}, fn
      {key, _}, acc when is_atom(key) -> acc
      {key, value}, acc when is_binary(key) -> Map.put(acc, key, value)
    end)
  end

  @doc """
  Return true if the entity is on the local server.
  """
  @spec local?(t) :: boolean
  def local?(%{__ap__: ap} = e) when APG.is_entity(e), do: Metadata.local?(ap)

  @doc """
  Return the status of the entity.

  See `ActivityPub.Metadata` for status codes.
  """
  @spec status(t) :: atom
  def status(%{__ap__: %{status: status}} = e) when APG.is_entity(e), do: status

  @doc """
  Return the local ID of the entity, if it is local.
  """
  @spec local_id(t) :: integer
  def local_id(%{__ap__: meta} = e) when APG.is_entity(e), do: Metadata.local_id(meta)

  @doc """
  ## `Entity` Persistence
  `ActivityPub.Entity` only works with `Entities` in memory during runtime. Persistence is a separate layer, so in theory, this would allow creating other persistence layers using different types of storage — for example, graph databases.

  Our current persistence layer is `ActivityPub.SQLEntity` which uses Ecto and Postgres.

  It is important to understand that `ActivityPub.SQLEntity` and `ActivityPub.Entity` are completely separate modules with completely separate functionality:

  * `ActivityPub.SQLEntity` receives an `ActivityPub.Entity` and stores it in the database.

  * When something is loaded from the database, `ActivityPub.SQLEntity` returns an `ActivityPub.Entity`.

  * `ActivityPub.SQLEntity` knows about `ActivityPub.Entity`, but `ActivityPub.Entity` shouldn’t know anything about `ActivityPub.SQLEntity` (apart from knowing the names of modules to use persistence of course).
  """
  @spec persistence(t) :: any
  def persistence(%{__ap__: %{persistence: persistence}} = e) when APG.is_entity(e), do: persistence
end
