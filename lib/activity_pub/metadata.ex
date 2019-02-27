defmodule ActivityPub.Metadata do
  @enforce_keys [:status, :verified]
  defstruct [
    aspects: %{},
    types: %{},
    status: nil,
    persistence: nil,
    local_id: nil,
    verified: false
  ]

  def new(type_list) do
    types = Enum.into(type_list, %{}, &{&1, true})
    aspect_list = ActivityPub.Types.aspects(type_list)
    aspects = Enum.into(aspect_list, %{}, &{&1, true})
    %__MODULE__{
      types: types,
      aspects: aspects,
      status: :new,
      persistence: nil,
      verified: true
    }
  end

  def not_loaded(local_id \\ nil)

  def not_loaded(nil) do
    %__MODULE__{
      status: :not_loaded,
      persistence: nil,
      verified: false,
      local_id: nil
    }
  end

  def not_loaded(local_id) do
    %__MODULE__{
      status: :not_loaded,
      persistence: nil,
      verified: true,
      local_id: local_id
    }
  end

  def load(sql) do
    types = Enum.into(sql.type, %{}, &{&1, true})
    aspect_list = ActivityPub.Types.aspects(sql.type)
    aspects = Enum.into(aspect_list, %{}, &{&1, true})
    %__MODULE__{
      types: types,
      aspects: aspects,
      status: :loaded,
      persistence: sql,
      local_id: sql.local_id,
      verified: true
    }
  end

  def aspects(%__MODULE__{aspects: aspect_map}) do
    Enum.map(aspect_map, fn {aspect, true} -> aspect end)
  end

  def types(%__MODULE__{types: type_map}) do
    Enum.map(type_map, fn {type, true} -> type end)
  end

  def local_id(%__MODULE__{local_id: local_id}), do: local_id

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

  defguard has_status(meta, status)
           when is_metadata(meta) and :erlang.map_get(:status, meta) == status

  defguard has_local_id(meta) when not(is_nil(:erlang.map_get(:local_id, meta)))
end
