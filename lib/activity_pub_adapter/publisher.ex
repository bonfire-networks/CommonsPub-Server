# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.ActivityPub.Publisher do
  require Logger

  # TODO: move specialised publish funcs to context modules (or make them extensible for extra types)

  @character_types [
    CommonsPub.Users.User,
    CommonsPub.Communities.Community,
    CommonsPub.Collections.Collection,
    CommonsPub.Characters.Character
  ]
  @thing_types [CommonsPub.Threads.Comment, CommonsPub.Resources.Resource]

  def publish("update", %{__struct__: type, id: id})
      when type in @character_types do
    # Works for Users, Collections, Communities (not MN.ActivityPub.Actor)
    with {:ok, actor} <- ActivityPub.Actor.get_by_local_id(id),
         actor_object <- ActivityPubWeb.ActorView.render("actor.json", %{actor: actor}),
         params <- %{
           to: [CommonsPub.ActivityPub.Utils.public_uri()],
           cc: [actor.data["followers"]],
           object: actor_object,
           actor: actor.ap_id,
           local: true
         } do
      ActivityPub.Actor.set_cache(actor)
      ActivityPub.update(params)
    else
      e -> {:error, e}
    end
  end

  def publish("delete", %CommonsPub.Users.User{} = user) do
    # is this broken?
    with actor <- CommonsPub.ActivityPub.Adapter.format_local_actor(user) do
      ActivityPub.Actor.set_cache(actor)
      ActivityPub.delete(actor)
    end
  end

  def publish("delete", %{__struct__: type} = character) when type in @character_types do
    # Works for Collections, Communities (not User or MN.ActivityPub.Actor)

    with {:ok, creator} <- ActivityPub.Actor.get_by_local_id(character.creator_id),
         actor <- CommonsPub.ActivityPub.Adapter.format_local_actor(character) do
      ActivityPub.Actor.invalidate_cache(actor)
      ActivityPub.delete(actor, true, creator.ap_id)
    end
  end

  def publish("delete", %{__struct__: type} = thing) when type in @thing_types do
    with %ActivityPub.Object{} = object <- ActivityPub.Object.get_cached_by_pointer_id(thing.id) do
      ActivityPub.delete(object)
    else
      e -> {:error, e}
    end
  end

  def publish(verb, %{__struct__: object_type} = local_object) do
    if(
      !is_nil(object_type) and
        Kernel.function_exported?(object_type, :context_module, 0)
    ) do
      object_context_module = apply(object_type, :context_module, [])

      if(Kernel.function_exported?(object_context_module, :ap_publish_activity, 2)) do
        # IO.inspect(function_exists_in: object_context_module)

        try do
          apply(object_context_module, :ap_publish_activity, [verb, local_object])
        rescue
          FunctionClauseError ->
            error(
              "Unsupported verb/object combination for AP publisher - no function matching #{
                object_context_module
              }.ap_publish_activity(\"#{verb}\", object)",
              verb,
              local_object
            )
        end
      else
        error(
          "Unsupported verb/object combination for AP publisher - no function matching #{
            object_context_module
          }.ap_publish_activity/2",
          verb,
          local_object
        )
      end
    else
      error(
        "Unsupported verb/object combination for AP publisher  (not a known type or context_module undefined) ",
        verb,
        local_object
      )
    end
  end

  def publish(verb, object) do
    error("Unrecognised object for AP publisher", verb, object)

    IO.inspect(object: object)

    :ignored
  end

  def error(error, verb, %{__struct__: object_type, id: id}) do
    Logger.error(
      "ActivityPub - Unable to federate - #{error}... object ID: #{id} ; verb: #{verb} ; object type: #{
        object_type
      }"
    )

    :ignored
  end

  def error(error, verb, object) do
    Logger.error("ActivityPub - Unable to federate - #{error}... verb: #{verb}}")

    IO.inspect(object: object)

    :ignored
  end
end
