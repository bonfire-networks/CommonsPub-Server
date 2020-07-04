defmodule MoodleNetWeb.Helpers.Activites do
  alias MoodleNet.{
    Repo,
    Meta.Pointers
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def prepare(activity) do
    activity =
      if(!is_nil(activity.context_id)) do
        {:ok, pointer} = Pointers.one(id: activity.context_id)
        context = Pointers.follow!(pointer)

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

    # IO.inspect(activity)

    activity
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})
    |> Map.merge(%{verb_object: activity_verb_object(activity)})
  end

  def activity_verb_object(%{verb: verb, context_type: context_type} = activity) do
    cond do
      activity.context_type == "flag" ->
        "flagged a " <> activity.context_type

      activity.context_type == "like" ->
        "starred a " <> activity.context_type

      activity.context_type == "follow" ->
        "followed a " <> activity.context_type

      activity.context_type == "resource" ->
        "added a " <> activity.context_type

      activity.context_type == "comment" ->
        cond do
          activity.context.reply_to_id ->
            "replied to a discussion"

          true ->
            "started a discussion"
        end

      activity.verb == "created" ->
        "created a " <> activity.context_type

      activity.verb == "updated" ->
        "updated a " <> activity.context_type

      true ->
        "acted on a " <> activity.context_type
    end
  end

  def activity_verb_object(%{verb: verb} = activity) do
    verb <> " something"
  end

  def activity_verb_object(%{context_type: context_type} = activity) do
    "did " <> context_type
  end

  def activity_verb_object(activity) do
    "did something"
  end
end
