defmodule ActivityPub.Entity do
  require ActivityPub.Guards, as: APG

  alias ActivityPub.{
    Context,
    Types,
    IRI,
    Metadata,
    ParseError
  }

  @internal_fields [:"@context", :id, :type, :__ap__]
  @internal_fields_string Enum.map(@internal_fields, &to_string/1)

  def aspects(entity = %{__ap__: meta}) when APG.is_entity(entity),
    do: Metadata.aspects(meta)

  def fields_for(entity, aspect) when APG.has_aspect(entity, aspect) do
    Map.take(entity, aspect.__aspect__(:fields))
  end

  def fields_for(_, _), do: %{}

  def extension_fields(entity) when APG.is_entity(entity) do
    Enum.reduce(entity, %{}, fn
      {key, _}, acc when is_atom(key) -> acc
      {key, value}, acc when is_binary(key) -> Map.put(acc, key, value)
    end)
  end

  def local?(%{__ap__: %{local: local}}), do: local

  @new_internal_fields @internal_fields ++ @internal_fields_string
  def new(params, inherited_context \\ nil) do
    params =
      params
      |> Map.take(@new_internal_fields)
      |> normalize_keys()

    with {:ok, context} <- parse_context(params, inherited_context),
         {:ok, types} <- Types.parse(params["type"]),
         {:ok, id} <- IRI.parse(params, "id") do

       aspects = ActivityPub.Types.aspects(types)
       # FIXME true by default when id is nil?
       local = if id, do: ActivityPub.UrlBuilder.local?(id), else: true
       meta_attrs =
         params
         |> Map.get("__ap__", [])
         |> Enum.into([])
         |> Keyword.put(:local, local)

       meta = Metadata.new(types, aspects, meta_attrs)
       {:ok, %{
        "@context": context,
        id: id,
        type: types,
        __ap__: meta
      }}
    end
  end

  def parse(params, inherited_context \\ nil, previous_keys \\ []) when is_list(previous_keys) do
    case do_parse(params, inherited_context, previous_keys) do
      {:error, %ParseError{} = error} -> handle_error(error, previous_keys)
      ret -> ret
    end
  end

  defp handle_error(error, []), do: {:error, error}

  defp handle_error(error, previous_keys) do
    key =
      [error.key | previous_keys]
      |> Enum.reverse()
      |> Enum.join(".")

    {:error, %{error | key: key}}
  end

  defp do_parse(id, _inherited_context, _previous_keys) when is_binary(id) do
    with {:ok, id} <- IRI.parse(%{"id" => id}, "id"),
         meta = Metadata.new([], [], local: true, status: :parsed) do
      {:ok, %{id: id, __ap__: meta}}
    end
  end

  defp do_parse(params, inherited_context, _previous_keys) when is_map(params) do
    # FIXME
    # params = Map.put(params, "__ap__", status: :parsed)

    with {:ok, entity} <- new(params, inherited_context) do
      params =
        params
        |> normalize_keys()
        |> Map.drop(@internal_fields_string)

      entity
      |> aspects()
      |> Enum.reduce({entity, params}, &cast_aspect(&2, &1))
      |> case do
        {:error, _} = ret ->
          ret

        {entity, params} ->
          {:ok, Map.merge(entity, params)}
      end
    end
  end

  defp parse_context(params, inherited_context) do
    case Context.parse(params["@context"]) do
      {:ok, nil} -> {:ok, inherited_context}
      r -> r
    end
  end

  defp cast_aspect({:error, _} = ret, _), do: ret

  defp cast_aspect({entity, params}, aspect) do
    context = entity[:"@context"]
    with {:ok, parsed, params} <- aspect.parse(params, context) do
      entity = Map.merge(entity, parsed)
      {entity, params}
    end
  end

  defp normalize_keys(%{} = params) do
    params
    |> Enum.into(%{}, fn {key, value} ->
      key = key |> to_string() |> Recase.to_snake()
      {key, value}
    end)
  end
end
