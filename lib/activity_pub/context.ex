defmodule ActivityPub.Context do
  # FIXME Sure this can be done much better
  # but I don't understand completely JSON-LD context

  defstruct values: [], language: "und"

  @behaviour Ecto.Type

  @impl Ecto.Type
  def type(), do: :map

  @impl Ecto.Type
  def cast(value) do
    case parse(value) do
      {:error, _} -> :error
      {:ok, _ } = ret -> ret
    end
  end

  @impl Ecto.Type
  def load(%{"no_prefix" => no_prefix, "language" => language} = map) do
    values = no_prefix ++
      map
      |> Map.drop(["no_prefix", "language"])
      |> Map.to_list()
    {:ok, %__MODULE__{
      language: language,
      values: values
    }}
  end

  @impl Ecto.Type
  def dump(%__MODULE__{values: values, language: language} = ctxt) do
    initial = %{"language" => language, "no_prefix" => []}
    ret = Enum.reduce(values, initial, fn
      {prefix, value}, map ->
        Map.put(initial, prefix, value)
      value, map when is_binary(value) ->
        %{map | values: [value | map.values]}
    end)

    {:ok, ret}
  end

  def dump(_), do: :error

  alias ActivityPub.ParseError

  def parse(value) do
    value
    |> List.wrap()
    |> Enum.reduce(%__MODULE__{}, &parse_single/2)
    |> case do
      {:error, _} = ret -> ret
      context -> {:ok, context}
    end
  end

  defp parse_single(_, {:error, _} = ret), do: ret

  defp parse_single(string, context) when is_binary(string) do
    %{context | values: [string | context.values]}
  end

  defp parse_single(map, context) when is_map(map) do
    Enum.reduce(map, context, &parse_single/2)
  end

  defp parse_single({"@language", lang}, context), do: %{context | language: lang}

  defp parse_single({prefix, value}, context) when is_binary(prefix) and is_binary(value),
    do: %{context | values: [{prefix, value} | context.values]}

  defp parse_single(invalid_value, context), do: {:error, %ParseError{key: "@context", value: invalid_value, message: "is invalid"}}
end
