defmodule ActivityPub.Metadata do
  defstruct aspects: %{}, types: %{}, status: nil, persistence: nil

  def new(type_list, aspect_list, status) do
    types = Enum.into(type_list, %{}, &{&1, true})
    aspects = Enum.into(aspect_list, %{}, &{&1, true})

    %__MODULE__{
      aspects: aspects,
      types: types,
      status: status
    }
  end

  def aspects(%__MODULE__{aspects: aspect_map}) do
    Enum.map(aspect_map, fn {aspect, true} -> aspect end)
  end

  def types(%__MODULE__{types: type_map} = meta) do
    Enum.map(type_map, fn {type, true} -> type end)
  end

  def inspect(%__MODULE__{} = meta, opts) do
    pruned = %{
      status: meta.status,
      persistence: meta.persistence,
      aspects: aspects(meta)
    }

    colorless_opts = %{opts | syntax_colors: []}
    Inspect.Map.inspect(pruned, Inspect.Atom.inspect(__MODULE__, colorless_opts), opts)
  end
end

defimpl Inspect, for: ActivityPub.Metadata do
  def inspect(meta, opts), do: ActivityPub.Metadata.inspect(meta, opts)
end

defmodule ActivityPub.Metadata.Guards do
  defguard is_metadata(meta) when :erlang.map_get(:__struct__, meta) == ActivityPub.Metadata

  defguard has_type(meta, type)
           when is_metadata(meta) and :erlang.map_get(type, :erlang.map_get(:types, meta))

  defguard has_aspect(meta, aspect)
           when is_metadata(meta) and :erlang.map_get(aspect, :erlang.map_get(:aspects, meta))
end
