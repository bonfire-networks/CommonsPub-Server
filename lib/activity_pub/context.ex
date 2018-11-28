defmodule ActivityPub.Context do
  defstruct values: [], language: "und"

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
