defmodule ActivityPub.Metadata.Helper do
  def from_type_to_field(type), do: "is_#{Recase.to_snake(type)}" |> String.to_atom()

  def from_field_to_type(field) do
    "is_" <> type = to_string(field)
    Recase.to_pascal(type)
  end
end

defmodule ActivityPub.Metadata do
  use Ecto.Schema

  import ActivityPub.Metadata.Helper

  @types ActivityPub.Types.all()
  Module.register_attribute(__MODULE__, :type_fields, accumulate: true)

  @primary_key false
  embedded_schema do
    field(:status, :string)
    field(:sql, :any, virtual: true)

    for type <- @types do
      field_name = from_type_to_field(type)
      @type_fields field_name
      field(field_name, :boolean, default: false)
    end
  end

  def build(types, status, sql \\ nil) when is_list(types) do
    Enum.reduce(types, %__MODULE__{sql: sql, status: status}, &add_type(&2, &1))
  end

  defp set_type(%__MODULE__{} = meta, type, value) when type in @types,
    do: Map.put(meta, from_type_to_field(type), value)

  defp set_type(%__MODULE__{} = meta, _type, _), do: meta

  def add_type(%__MODULE__{} = meta, type) when is_binary(type), do: set_type(meta, type, true)

  def remove_type(%__MODULE__{} = meta, type) when is_binary(type),
    do: set_type(meta, type, false)

  def types(%__MODULE__{} = meta) do
    meta
    |> Map.to_list()
    |> Enum.reduce([], fn
      {key, true}, acc when key in @type_fields ->
        [from_field_to_type(key) | acc]

      _, acc ->
        acc
    end)
  end

  def inspect(%__MODULE__{} = meta, opts) do
    pruned = %{
      status: meta.status,
      types: types(meta)
    }

    colorless_opts = %{opts | syntax_colors: []}
    Inspect.Map.inspect(pruned, Inspect.Atom.inspect(__MODULE__, colorless_opts), opts)
  end
end

defimpl Inspect, for: ActivityPub.Metadata do
  def inspect(meta, opts), do: ActivityPub.Metadata.inspect(meta, opts)
end
