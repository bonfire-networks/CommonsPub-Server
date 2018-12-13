defmodule ActivityPub.Context do
  # FIXME Sure this can be done much better
  # but I don't understand completely JSON-LD context

  defstruct values: [], language: "und"

  @activity_pub_ns "https://www.w3.org/ns/activitystreams"
  def default(), do: %__MODULE__{values: [@activity_pub_ns]}

  @behaviour Ecto.Type

  @impl Ecto.Type
  def type(), do: :map

  @impl Ecto.Type
  def cast(value) do
    case build(value) do
      {:error, _} -> :error
      {:ok, _ } = ret -> ret
    end
  end

  @impl Ecto.Type
  def load(%{"no_prefix" => no_prefix, "language" => language} = map) do
    values =
      map
      |> Map.drop(["no_prefix", "language"])
      |> Map.to_list()
    values = values ++ no_prefix
    {:ok, %__MODULE__{
      language: language,
      values: values
    }}
  end

  @impl Ecto.Type
  def dump(%__MODULE__{values: values, language: language}) do
    initial = %{"language" => language, "no_prefix" => []}
    ret = Enum.reduce(values, initial, fn
      {prefix, value}, map ->
        Map.put(map, prefix, value)
      value, map when is_binary(value) ->
        %{map | "no_prefix" => [value | map["no_prefix"]]}
    end)

    {:ok, ret}
  end

  def dump(_), do: :error

  alias ActivityPub.BuildError

  def build(value) do
    value
    |> List.wrap()
    |> Enum.reduce(%__MODULE__{}, &build_single/2)
    |> case do
      {:error, _} = ret -> ret
      context -> {:ok, context}
    end
  end

  defp build_single(_, {:error, _} = ret), do: ret

  defp build_single(string, context) when is_binary(string) do
    %{context | values: [string | context.values]}
  end

  defp build_single(map, context) when is_map(map) do
    Enum.reduce(map, context, &build_single/2)
  end

  defp build_single({"@language", lang}, context), do: %{context | language: lang}

  defp build_single({prefix, value}, context) when is_binary(prefix) and is_binary(value),
    do: %{context | values: [{prefix, value} | context.values]}

  defp build_single(invalid_value, _context), do: {:error, %BuildError{path: ["@context"], value: invalid_value, message: "is invalid"}}
end
