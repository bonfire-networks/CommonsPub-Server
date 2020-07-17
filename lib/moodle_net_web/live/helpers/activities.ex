defmodule MoodleNetWeb.Helpers.Activites do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def prepare(%MoodleNet.Activities.Activity{} = activity) do
    prepare_activity(activity)
  end

  def prepare(%MoodleNet.Likes.Like{} = activity) do
    prepare_activity(activity)
  end

  def prepare(activity) do
    activity
  end

  def prepare_activity(activity) do
    MoodleNet.Repo.preload(activity, :context)

    activity =
      if(Map.has_key?(activity, :context_id) and !is_nil(activity.context_id)) do
        {:ok, pointer} = MoodleNet.Meta.Pointers.one(id: activity.context_id)
        context = MoodleNet.Meta.Pointers.follow!(pointer)

        type =
          context.__struct__
          |> Module.split()
          |> Enum.at(-1)
          |> String.downcase()

        activity
        |> Map.merge(%{context_type: type})
        |> Map.merge(%{context: context})
      else
        activity
      end

    activity = Repo.preload(activity, :creator)

    creator = Profiles.prepare(activity.creator, %{icon: true, actor: true})

    {:ok, from_now} =
      Timex.shift(activity.published_at, minutes: -3)
      |> Timex.format("{relative}", :relative)

    # IO.inspect(prepare_activity: activity)

    activity
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})
    |> Map.merge(%{display_verb: display_activity_verb(activity)})
    |> Map.merge(%{display_object: display_activity_object(activity)})
    |> Map.merge(%{activity_url: activity_url(activity)})
  end

  def activity_url(%{
        context: %MoodleNet.Communities.Community{
          actor: %{preferred_username: preferred_username}
        }
      })
      when not is_nil(preferred_username) do
    "/&" <> preferred_username
  end

  def activity_url(%{
        context: %MoodleNet.Users.User{
          actor: %{preferred_username: preferred_username}
        }
      })
      when not is_nil(preferred_username) do
    "/@" <> preferred_username
  end

  def activity_url(%{
        context: %{
          actor: %{preferred_username: preferred_username}
        }
      })
      when not is_nil(preferred_username) do
    "/+" <> preferred_username
  end

  def activity_url(%{context: %{thread_id: thread_id, id: comment_id, reply_to_id: is_reply}})
      when not is_nil(thread_id) and not is_nil(is_reply) do
    "/!" <> thread_id <> "/discuss/" <> comment_id <> "#reply"
  end

  def activity_url(%{context: %{thread_id: thread_id}}) when not is_nil(thread_id) do
    "/!" <> thread_id
  end

  def activity_url(%{context: %{canonical_url: canonical_url}}) when not is_nil(canonical_url) do
    canonical_url
  end

  def activity_url(%{context: %{actor: %{canonical_url: canonical_url}}})
      when not is_nil(canonical_url) do
    canonical_url
  end

  def activity_url(%{canonical_url: canonical_url}) when not is_nil(canonical_url) do
    canonical_url
  end

  def activity_url(activity) do
    IO.inspect(activity)
    "#unsupported-by-activity_url/1"
  end

  def display_activity_verb(%MoodleNet.Likes.Like{}) do
    "favourited"
  end

  def display_activity_verb(%{verb: verb, context_type: context_type} = activity) do
    cond do
      context_type == "flag" ->
        "flagged"

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

          activity.context.name ->
            "posted:"

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

      # activity.context.name ->
      #   "a " <> context_type <> ": " <> activity.context.name

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
