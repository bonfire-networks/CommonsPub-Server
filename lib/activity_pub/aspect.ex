defmodule ActivityPub.Aspect do
  alias ActivityPub.{Association, Context, ParseError}
  alias ActivityPub.Entity

  # FIXME make this more dynamic?
  @type_aspects %{
    # "Link" => [ActivityPub.LinkAspect],
    "Object" => [ActivityPub.ObjectAspect]
  }

  @aspects @type_aspects |> Map.values() |> List.flatten() |> Enum.uniq()
  def all(), do: @aspects

  def for_type(type) when is_binary(type), do: Map.get(@type_aspects, type, [])

  def for_types(types) when is_list(types),
    do: Enum.flat_map(types, &Map.get(@type_aspects, &1, []))

  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      persistence = Keyword.fetch!(options, :persistence)

      def persistence(), do: unquote(persistence)

      import ActivityPub.Aspect, only: [aspect: 1]

      Module.register_attribute(__MODULE__, :aspect_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :aspect_assocs, accumulate: true)
      Module.register_attribute(__MODULE__, :aspect_struct_fields, accumulate: true)

      @name __MODULE__
            |> Module.split()
            |> List.last()
            |> Recase.to_snake()
            |> String.to_atom()

      def name(), do: @name

      def parse(params, %Context{} = context) when is_map(params) do
        ActivityPub.Aspect.parse(__MODULE__, params, context)
      end
    end
  end

  defmacro aspect(do: block) do
    define_aspect(block)
  end

  def define_aspect(block) do
    prelude =
      quote do
        @after_compile ActivityPub.Aspect

        try do
          import ActivityPub.Aspect
          unquote(block)
        after
          :ok
        end
      end

    postlude =
      quote unquote: false do
        fields = @aspect_fields |> Enum.reverse()
        assocs = @aspect_assocs |> Enum.reverse()

        def __aspect__(:fields), do: unquote(Enum.map(fields, &elem(&1, 0)))
        def __aspect__(:associations), do: unquote(Enum.map(assocs, &elem(&1, 0)))

        for clauses <- ActivityPub.Aspect.__aspect__(fields, assocs),
            {args, body} <- clauses do
          def __aspect__(unquote_splicing(args)), do: unquote(body)
        end
      end

    quote do
      unquote(prelude)
      unquote(postlude)
    end
  end

  defmacro field(name, type \\ :string, opts \\ []) do
    quote do
      ActivityPub.Aspect.__field__(__MODULE__, unquote(name), unquote(type), unquote(opts))
    end
  end

  def __field__(mod, name, type, opts) do
    check_field_type!(name, type, opts)
    define_field(mod, name, type, opts)
  end

  # TODO
  defp check_field_type!(name, :datetime, _opts) do
    raise ArgumentError,
          "invalid type :datetime for field #{inspect(name)}. " <>
            "You probably meant to choose one between :naive_datetime " <>
            "(no time zone information) or :utc_datetime (time zone is set to UTC)"
  end

  defp check_field_type!(name, {:embed, _}, _opts) do
    raise ArgumentError,
          "cannot declare field #{inspect(name)} as embed. Use embeds_one/many instead"
  end

  defp check_field_type!(name, type, _opts) do
    cond do
      Ecto.Type.primitive?(type) ->
        type

      is_atom(type) and Code.ensure_compiled?(type) and function_exported?(type, :type, 0) ->
        type

      is_atom(type) and function_exported?(type, :__schema__, 1) ->
        raise ArgumentError,
              "schema #{inspect(type)} is not a valid type for field #{inspect(name)}."

      true ->
        raise ArgumentError, "invalid or unknown type #{inspect(type)} for field #{inspect(name)}"
    end
  end

  defp define_field(mod, name, type, opts) do
    Module.put_attribute(mod, :aspect_fields, {name, type})
    put_struct_field(mod, name, Keyword.get(opts, :default))
  end

  defp put_struct_field(mod, name, default) do
    fields = Module.get_attribute(mod, :aspect_struct_fields)

    if List.keyfind(fields, name, 0) do
      raise ArgumentError, "field/association #{inspect(name)} is already set on aspect"
    end

    Module.put_attribute(mod, :aspect_struct_fields, {name, default})
  end

  def __aspect__(fields, _assocs) do
    types_quoted =
      for {name, type} <- fields do
        {[:type, name], Macro.escape(type)}
      end

    [
      types_quoted
    ]
  end

  defmacro assoc(name, opts \\ []) do
    quote do
      ActivityPub.Aspect.__assoc__(__MODULE__, unquote(name), unquote(opts))
    end
  end

  def __assoc__(mod, name, opts) do
    assoc = struct(Association, opts)
    Module.put_attribute(mod, :aspect_assocs, {name, assoc})
    put_struct_field(mod, name, assoc)
  end

  @doc false
  def __after_compile__(%{module: _module} = _env, _) do
    :ok
  end

  def parse(aspect, params, context, previous_keys \\ []) do
    params = convert_params(params)

    try do
      fields = aspect.__aspect__(:fields)

      {parsed, params} =
        Enum.reduce(fields, {%{}, params}, &process_param(&1, &2, aspect, context))

      assocs = aspect.__aspect__(:associations)

      {parsed, params} =
        Enum.reduce(
          assocs,
          {parsed, params},
          &process_assoc(&1, &2, aspect, context, previous_keys)
        )

      {:ok, parsed, params}
    catch
      {:error, _} = ret -> ret
    end
  end

  defp process_param(key, {parsed, params}, aspect, context) do
    type = aspect.__aspect__(:type, key)

    case cast_param(type, to_string(key), params, context) do
      {:ok, value, params} ->
        parsed = Map.put(parsed, key, value)
        {parsed, params}

      {:error, value} ->
        error = %ParseError{key: to_string(key), value: value, message: "is invalid"}
        throw({:error, error})
    end
  end

  defp cast_param(ActivityPub.LanguageValueType, key, params, %{language: lang}) do
    map_key = "#{key}_map"
    value = Map.get(params, map_key) || Map.get(params, key)
    params = params |> Map.delete(key) |> Map.delete(map_key)

    with {:ok, value} <- ActivityPub.LanguageValueType.cast(value, lang) do
      {:ok, value, params}
    else
      _ -> {:error, value}
    end
  end

  defp cast_param(type, key, params, _) do
    {value, params} = Map.pop(params, key)

    with {:ok, value} <- Ecto.Type.cast(type, value) do
      {:ok, value, params}
    else
      _ -> {:error, value}
    end
  end

  defp process_assoc(key, {parsed, params}, _aspect, context, previous_keys) do
    {value, params} = Map.pop(params, to_string(key))

    previous_keys = [key | previous_keys]

    assocs =
      value
      |> List.wrap()
      |> Enum.with_index()
      |> Enum.map(fn {assoc_params, index} ->
        case Entity.parse(assoc_params, context, [index | previous_keys]) do
          {:ok, assoc} -> assoc
          {:error, _} = ret -> throw(ret)
        end
      end)

    parsed = Map.put(parsed, key, assocs)

    {parsed, params}
  end

  defp convert_params(params) do
    params
    |> Enum.reduce(nil, fn
      {key, _value}, nil when is_binary(key) ->
        nil

      {key, _value}, _ when is_binary(key) ->
        raise Ecto.CastError,
          type: :map,
          value: params,
          message:
            "expected params to be a map with atoms or string keys, " <>
              "got a map with mixed keys: #{inspect(params)}"

      {key, value}, nil when is_atom(key) ->
        [{Atom.to_string(key), value}]

      {key, value}, acc when is_atom(key) ->
        [{Atom.to_string(key), value} | acc]
    end)
    |> case do
      nil -> params
      list -> :maps.from_list(list)
    end
  end
end
