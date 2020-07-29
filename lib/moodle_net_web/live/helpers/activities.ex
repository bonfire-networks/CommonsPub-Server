defmodule MoodleNetWeb.Helpers.Activites do
  alias MoodleNet.{
    Repo
  }

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Helpers.{Profiles}

  def prepare(%{display_verb: _, display_object: _} = activity, current_user) do
    IO.inspect("activity already prepared")
    activity
  end

  def prepare(%{:__struct__ => _} = activity, current_user) do
    activity = maybe_preload(activity, :creator)
    prepare_activity(activity, current_user)
  end

  def prepare(activity, current_user) do
    prepare_activity(activity, current_user)
  end

  defp prepare_activity(activity, current_user) do
    # guess what type of thing we're dealing with
    activity = prepare_context(activity)

    # get the OP
    creator = Profiles.prepare(activity.creator, %{icon: true, actor: true})

    # IO.inspect(activity.published_at)

    # a friendly date
    from_now = activity_date_from_now(activity)

    # IO.inspect(prepare_activity: activity)

    activity
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})
    |> Map.merge(%{display_verb: display_activity_verb(activity)})
    |> Map.merge(%{display_object: display_activity_object(activity)})
    |> Map.merge(%{activity_url: activity_url(activity)})
  end

  def activity_date_from_now(activity) do
    if Map.has_key?(activity, :published_at) and strlen(activity.published_at) > 0 do
      date_from_now(activity.published_at)
    else
      if Map.has_key?(activity, :updated_at) and strlen(activity.updated_at) > 0,
        do: date_from_now(activity.updated_at)
    end
  end

  def activity_url(
        %{
          context: %Ecto.Association.NotLoaded{}
        } = activity
      ) do
    activity = maybe_preload(activity, :context)
    activity_url(activity)
  end

  def activity_url(%{
        context: %{} = context
      }) do
    context_url(context)
  end

  def activity_url(%{} = activity) do
    context_url(activity)
  end

  def context_url(%MoodleNet.Communities.Community{
        actor: %{preferred_username: preferred_username}
      })
      when not is_nil(preferred_username) do
    "/&" <> preferred_username
  end

  def context_url(%MoodleNet.Users.User{
        actor: %{preferred_username: preferred_username}
      })
      when not is_nil(preferred_username) do
    "/@" <> preferred_username
  end

  def context_url(%{
        actor: %{preferred_username: preferred_username}
      })
      when not is_nil(preferred_username) do
    "/+" <> preferred_username
  end

  def context_url(%{thread_id: thread_id, id: comment_id, reply_to_id: is_reply})
      when not is_nil(thread_id) and not is_nil(is_reply) do
    "/!" <> thread_id <> "/discuss/" <> comment_id <> "#reply"
  end

  def context_url(%{thread_id: thread_id}) when not is_nil(thread_id) do
    "/!" <> thread_id
  end

  def context_url(%{canonical_url: canonical_url}) when not is_nil(canonical_url) do
    canonical_url
  end

  def context_url(%{actor: %{canonical_url: canonical_url}})
      when not is_nil(canonical_url) do
    canonical_url
  end

  def context_url(%{__struct__: module_name} = activity) do
    IO.inspect(unsupported_by_activity_url: module_name)
    "#unsupported_by_activity_url/" <> to_string(module_name)
  end

  def context_url(activity) do
    IO.inspect(unsupported_by_activity_url: activity)
    "#unsupported_by_activity_url"
  end

  def display_activity_verb(%{display_verb: display_verb}) do
    display_verb
  end

  def display_activity_verb(%MoodleNet.Likes.Like{}) do
    "favourited"
  end

  def display_activity_verb(%MoodleNet.Threads.Comment{}) do
    "posted"
  end

  def display_activity_verb(%{verb: verb, context_type: context_type} = activity) do
    cond do
      context_type == "flag" ->
        "flagged:"

      context_type == "like" ->
        "favourited"

      context_type == "follow" ->
        "followed"

      context_type == "resource" ->
        "added"

      context_type == "comment" ->
        cond do
          !is_nil(activity.context.reply_to_id) and !is_nil(activity.context.name) ->
            "replied to:"

          activity.context.reply_to_id ->
            "replied to"

          Map.has_key?(activity.context, :name) and strlen(activity.context.name) > 0 ->
            "posted:"

          Map.has_key?(activity.context, :message) and strlen(activity.context.message) > 0 ->
            "said:"

          true ->
            "started"
        end

      verb == "created" ->
        "created"

      verb == "updated" ->
        "updated"

      true ->
        "acted on"
    end
  end

  def display_activity_verb(%{verb: verb}) do
    verb
  end

  def display_activity_verb(%{context_type: context_type}) do
    "acted on"
  end

  def display_activity_verb(_) do
    "did"
  end

  def display_activity_object(%{verb: verb, context_type: context_type} = activity) do
    cond do
      context_type == "comment" ->
        cond do
          activity.context.name ->
            activity.context.name

          true ->
            "a discussion"
        end

      context_type == "like" ->
        ""

      Map.has_key?(activity.context, :name) and strlen(activity.context.name) > 0 ->
        "a " <> context_type <> ": " <> activity.context.name

      Map.has_key?(activity.context, :message) and strlen(activity.context.message) > 0 ->
        "«" <> activity.context.message <> "»"

      true ->
        "a " <> context_type
    end
  end

  def display_activity_object(%{context_type: context_type}) do
    "a " <> context_type
  end

  def display_activity_object(_) do
    "something"
  end
end
