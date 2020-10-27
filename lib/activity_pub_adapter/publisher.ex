# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.ActivityPub.Publisher do
  require Logger

  alias CommonsPub.Collections.Collection
  alias CommonsPub.Communities.Community
  alias CommonsPub.Resources.Resource
  alias CommonsPub.Threads.Comment
  alias CommonsPub.Users.User

  # TODO: move specialised publish funcs to context modules

  def publish("update", %{__struct__: type} = character)
      when type in [User, Community, Collection] do
    update_character(character)
  end

  def publish("delete", %User{} = user) do
    delete_user(user)
  end

  def publish("delete", %{__struct__: type} = character)
      when type in [Community, Collection] do
    delete_character(character)
  end

  def publish("delete", %{__struct__: type} = object) when type in [Comment, Resource] do
    delete_comment_or_resource(object)
  end

  def publish(verb, %{__struct__: object_type, id: id} = local_object) do
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

  def delete_comment_or_resource(comment) do
    with %ActivityPub.Object{} = object <- ActivityPub.Object.get_cached_by_pointer_id(comment.id) do
      ActivityPub.delete(object)
    else
      e -> {:error, e}
    end
  end

  # Works for Users, Collections, Communities (not MN.ActivityPub.Actor)
  def update_character(%{id: id} = _character) do
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

  # Currently broken (it's hard)
  def delete_user(actor) do
    with actor <- CommonsPub.ActivityPub.Adapter.format_local_actor(actor) do
      ActivityPub.Actor.set_cache(actor)
      ActivityPub.delete(actor)
    end
  end

  # Works for Collections, Communities (not User or MN.ActivityPub.Actor)
  def delete_character(actor) do
    with {:ok, creator} <- ActivityPub.Actor.get_by_local_id(actor.creator_id),
         actor <- CommonsPub.ActivityPub.Adapter.format_local_actor(actor) do
      ActivityPub.Actor.invalidate_cache(actor)
      ActivityPub.delete(actor, true, creator.ap_id)
    end
  end

  def error(error, verb, %{__struct__: object_type, id: id}) do
    Logger.error(
      "ActivityPub - Unable to federate - Unsupported verb/object combination for AP publisher  (not a known type or context_module undefined)... object ID: #{
        id
      } ; verb: #{verb} ; object type: #{object_type}"
    )

    :ignored
  end

  def error(error, verb, object) do
    Logger.error("ActivityPub - Unable to federate - #{error}... verb: #{verb}}")

    IO.inspect(object: object)

    :ignored
  end
end
