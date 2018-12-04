defmodule ActivityPub.Entity do
  require ActivityPub.Guards, as: APG

  alias ActivityPub.{Metadata}

  def aspects(entity = %{__ap__: meta}) when APG.is_entity(entity),
    do: Metadata.aspects(meta)

  def fields_for(entity, aspect) when APG.has_aspect(entity, aspect) do
    Map.take(entity, aspect.__aspect__(:fields))
  end

  def fields_for(_, _), do: %{}

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

  def extension_fields(entity) when APG.is_entity(entity) do
    Enum.reduce(entity, %{}, fn
      {key, _}, acc when is_atom(key) -> acc
      {key, value}, acc when is_binary(key) -> Map.put(acc, key, value)
    end)
  end

  def local?(%{id: id} = e) when APG.is_entity(e) and not is_nil(id),
    do: ActivityPub.UrlBuilder.local?(id)

  def local?(%{id: nil} = e) when APG.is_entity(e), do: status(e) == :new

  def status(%{__ap__: %{status: status}} = e) when APG.is_entity(e), do: status

  def local_id(%{__ap__: %{persistence: nil}} = e) when APG.is_entity(e), do: nil
  def local_id(%{__ap__: %{persistence: sql}} = e) when APG.is_entity(e), do: sql.local_id

  def persistence(%{__ap__: %{persistence: persistence}} = e) when APG.is_entity(e), do: persistence
end
