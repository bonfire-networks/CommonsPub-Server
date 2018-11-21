defmodule MoodleNetWeb.GraphQL.Resolvers.Accounts do

  def user_map(user) do
    %{
      id: user.id,
      email: user.email,
      actor: actor_by_id(user.primary_actor_id),
    }
  end

  def current_user(user) do

    {:ok, user_map(user) }

  end

  def actor_map(actor) do
    %{
        id: actor.id,
        nickname: actor.preferred_username,
        name: actor.name,
        uri: actor.uri,
        icon: actor.avatar,
        local: actor.local,
        summary: actor.summary,
        types: actor.type,
        # user: actor.primaryUser,
        json: actor.info,
    }
  end

  def actor_by_id(id) do

    {:ok, actor = ActivityPub.get_actor!(id)}

    actor_map(actor)
  end

  def actor(_parent, _args, _resolution) do

    {:ok, actor_by_id(_args.id) }

  end

  # def current_actor(_parent, _args, _resolution) do
  #   ## TODO - get actor ID of currently authed user

  #   %{context: %{current_user: current_user}}
  #   {:ok, actor = ActivityPub.get_actor!(current_user.id)}

  #   {:ok, actor_map(actor)}
  # end

  def actors(_parent, _args, _resolution) do

    {:ok, actors = ActivityPub.list_actors!()}

    {:ok, Enum.map(actors, fn actor -> actor_map(actor) end)}
  end

  def user_create(_parent, _args, _resolution) do

    {:ok, MoodleNet.Accounts.register_user(_args.user) }

  end

end
