defmodule ActivityPub.Entito do
  require ActivityPub.Guards, as: APG

  alias ActivityPub.{
    Context,
    Types,
    IRI,
    Aspect,
    Metadata,
    ParseError
  }

  def aspects(entity = %{__ap__: meta}) when APG.is_entity(entity),
    do: Metadata.aspects(meta)

  def fields_for(entity, aspect) when APG.has_aspect(entity, aspect) do
    Map.take(entity, aspect.__aspect__(:fields))
  end

  def fields_for(_, _), do: %{}

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

  defp do_parse(id, inherited_context, _previous_keys) when is_binary(id) do
    with {:ok, id} <- IRI.parse(%{"id" => id}, "id"),
         meta = Metadata.new([], [], :parsed) do
      {:ok, %{id: id, __ap__: meta}}
    end
  end

  defp do_parse(params, inherited_context, _previous_keys) when is_map(params) do
    params = normalize_params(params)

    with {:ok, context} <- parse_context(params, inherited_context),
         {:ok, types} <- Types.parse(params["type"]),
         {:ok, id} <- IRI.parse(params, "id"),
         aspects = ActivityPub.Aspect.for_types(types),
         meta = Metadata.new(types, aspects, :parsed) do
      entity = %{
        context: context,
        id: id,
        type: types,
        __ap__: meta
      }

      params = Map.drop(params, ["@context", "id", "type"])

      case Enum.reduce(aspects, {entity, params}, &cast_aspect(&2, &1, context)) do
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

  defp cast_aspect({:error, _} = ret, _, _), do: ret

  defp cast_aspect({entity, params}, aspect, context) do
    with {:ok, parsed, params} <- aspect.parse(params, context) do
      entity = Map.merge(entity, parsed)
      {entity, params}
    end
  end

  defp normalize_params(%{} = params) do
    params
    |> Enum.into(%{}, fn {key, value} ->
      key = key |> to_string() |> Recase.to_snake()
      {key, value}
    end)
  end
end
