# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Aspect do
  @moduledoc """
  We focus on `Aspects` instead of working directly with ActivityPub _types_. An `Aspect`—a concept we coined as well—is a group of fields and functionality that any `ActivityPub.Entity` can have.

  The clearest example of an `Aspect` is [_Actor_ as defined in the ActivityPub specifications](https://www.w3.org/TR/activitypub/#actors), which we implemented as `ActivityPub.ActorAspect`. There are different _Actor_ types: _Application, Group, Person_, etc. but all of them can have the properties: _inbox, outbox, followers_, etc.

  The `Aspect` is responsible for an `ActivityPub.Entity`'s fields and associations.

  An `ActivityPub.Entity` can implement one or more aspects at the same time. So a _Person_, in addition of the `ActivityPub.ActorAspect`, also has the `ActivityPub.ObjectAspect` which contains all the fields that any _Object_ has: _id, type, attachment, audience, bcc, bto_, etc.

  `Aspects` are similar to [ActivityStreams core types](https://www.w3.org/TR/activitystreams-vocabulary/#types), but not exactly the same. Some of them match with the `Aspect` we define in the generic library—and the fields defined in each one too: `ActivityPub.ActivityAspect`, `ActivityPub.CollectionAspect`, `ActivityPub.LinkAspect` and `ActivityPub.ObjectAspect`.

  This [DSL](https://elixir-lang.org/getting-started/meta/domain-specific-languages.html) is used to define _Aspect_.

  The architecture is very similar to Ecto's. We store the different fields and association that an aspect has and we create a schema. An `ActivityPub.Entity` can have one or more aspects (this is defined in [activity_pub/entity.ex](https://gitlab.com/moodlenet/servers/federated/blob/develop/lib/activity_pub/entity.ex)).

  Any aspect module will generate the `__aspect__` function that can be used for runtime introspection of the aspect. This concept is key for the library and it is used continuously. `ActivityPub.AspectTest` has simple example of this introspection: [/test/activity_pub/aspect_test.exs#L15](https://gitlab.com/moodlenet/servers/federated/blob/develop/test/activity_pub/aspect_test.exs#L15). A more complex example is `ActivityPub.Entity.fields_for/2`.

  The `Aspect` DSL allows us to also define non-standard aspects (_meaning they are ActivityStreams extensions_), for our specific project. We define 3 aspects for MoodleNet in [moodle_net/activity_pub/](https://gitlab.com/moodlenet/servers/federated/tree/develop/lib/moodle_net/activity_pub): `MoodleNet.AP.CommunityAspect`, `MoodleNet.AP.CollectionAspect`, and `MoodleNet.AP.ResourceAspect`.
  """

  alias ActivityPub.{Field, Association}

  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      persistence = Keyword.fetch!(options, :persistence)

      def persistence(), do: unquote(persistence)

      import ActivityPub.Aspect, only: [aspect: 1]

      Module.register_attribute(__MODULE__, :aspect_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :aspect_assocs, accumulate: true)
      Module.register_attribute(__MODULE__, :aspect_struct_fields, accumulate: true)

      # FIXME better name than "name"
      @name __MODULE__
            |> Module.split()
            |> List.last()
            |> Recase.to_snake()
            |> String.to_atom()
      @name Keyword.get(options, :name, @name)
      def name(), do: @name

      # FIXME better name than "short_name"
      @short_name @name |> to_string() |> String.trim_trailing("_aspect") |> String.to_atom()
      @short_name Keyword.get(options, :short_name, @short_name)
      def short_name(), do: @short_name
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
          "Invalid type :datetime for field #{inspect(name)}. " <>
            "You probably meant to choose one of :naive_datetime " <>
            "(no time zone information) or :utc_datetime (time zone is set to UTC)"
  end

  defp check_field_type!(name, {:embed, _}, _opts) do
    raise ArgumentError,
          "Cannot declare field #{inspect(name)} as embed. Use embeds_one/many instead"
  end

  defp check_field_type!(name, type, _opts) do
    cond do
      Ecto.Type.primitive?(type) ->
        type

      is_atom(type) and Code.ensure_compiled?(type) and function_exported?(type, :type, 0) ->
        type

      is_atom(type) and function_exported?(type, :__schema__, 1) ->
        raise ArgumentError,
              "Schema #{inspect(type)} is not a valid type for field #{inspect(name)}."

      true ->
        raise ArgumentError, "Invalid or unknown type #{inspect(type)} for field #{inspect(name)}"
    end
  end

  defp define_field(mod, name, type, opts) do
    opts =
      opts
      |> Keyword.put(:aspect, mod)
      |> Keyword.put(:name, name)
      |> Keyword.put(:type, type)

    field = Field.build(opts)
    Module.put_attribute(mod, :aspect_fields, {name, field})
    put_struct_field(mod, name, Keyword.get(opts, :default))
  end

  defp put_struct_field(mod, name, default) do
    fields = Module.get_attribute(mod, :aspect_struct_fields)

    if List.keyfind(fields, name, 0) do
      raise ArgumentError, "Field/association #{inspect(name)} is already set on aspect"
    end

    Module.put_attribute(mod, :aspect_struct_fields, {name, default})
  end

  def __aspect__(fields, assocs) do
    types_quoted =
      for {name, field} <- fields do
        {[:type, name], Macro.escape(field.type)}
      end

    field_quoted =
      for {name, field} <- fields do
        {[:field, name], Macro.escape(field)}
      end

    assoc_quoted =
      for {name, assoc} <- assocs do
        {[:association, name], Macro.escape(assoc)}
      end

    [types_quoted, field_quoted, assoc_quoted]
  end

  defmacro assoc(name, opts \\ []) do
    quote do
      ActivityPub.Aspect.__assoc__(__MODULE__, unquote(name), unquote(opts))
    end
  end

  def __assoc__(mod, name, opts) do
    opts =
      opts
      |> Keyword.put(:aspect, mod)
      |> Keyword.put(:name, name)

    assoc = struct(Association, opts)
    Module.put_attribute(mod, :aspect_assocs, {name, assoc})
    put_struct_field(mod, name, assoc)
  end

  @doc false
  def __after_compile__(%{module: _module} = _env, _) do
    :ok
  end

  def build_assocs(aspect, entity, params) do
    params = Map.drop(params, aspect.__aspect__(:associations))
    {:ok, entity, params}
  end
end
