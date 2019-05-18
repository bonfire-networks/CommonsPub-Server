defmodule ActivityPub.Guards do
    @moduledoc """
Thanks to the `ActivityPub.Metadata` struct we can use some guards to make this library work in a similar way to Elixir's regular structs.

This allows us to create clauses depending on:

*   If the object is an AP entity
*   The aspects that it implements
*   The types that it has
*   If the entity is local or not
*   If the entity is new, loaded, fetched, etc

Example: In the `ActivityPub.SQLEntity.insert/2` function we only allow an `ActivityPub.Entity` whose state is :new
  """

  alias ActivityPub.Metadata.Guards, as: APMG
  require APMG

  defguard is_entity(e) when APMG.is_metadata(:erlang.map_get(:__ap__, e))
  defguard is_local(e) when APMG.is_local(:erlang.map_get(:__ap__, e))
  defguard has_type(e, type) when APMG.has_type(:erlang.map_get(:__ap__, e), type)
  defguard has_aspect(e, aspect) when APMG.has_aspect(:erlang.map_get(:__ap__, e), aspect)
  defguard has_status(e, status) when APMG.has_status(:erlang.map_get(:__ap__, e), status)
  defguard has_local_id(e) when APMG.has_local_id(:erlang.map_get(:__ap__, e))

  defmacro status(e) do
    quote bind_quoted: [e: e] do
      :erlang.map_get(:status, :erlang.map_get(:meta, e))
    end
  end

end
