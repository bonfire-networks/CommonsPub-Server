defmodule MoodleNetWeb.Helpers.Activites do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def prepare(activity) do
    activity =
      if(!is_nil(activity.context_id)) do
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

    # IO.inspect(activity)

    activity
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})
    |> Map.merge(%{verb_object: activity_verb_object(activity)})
  end

  def activity_verb_object(%{verb: verb, context_type: context_type} = activity) do
    cond do
      context_type == "flag" ->
        "flagged a " <> context_type

      context_type == "like" ->
        "starred a " <> context_type

      context_type == "follow" ->
        "followed a " <> context_type

      context_type == "resource" ->
        "added a " <> context_type

      context_type == "comment" ->
        cond do
          !is_nil(activity.context.reply_to_id) and !is_nil(activity.context.name) ->
            "replied to " <> activity.context.name

          activity.context.reply_to_id ->
            "replied to a discussion"

          activity.context.name ->
            "started a discussion: " <> activity.context.name

          true ->
            "started a discussion"
        end

      verb == "created" ->
        "created a " <> context_type

      verb == "updated" ->
        "updated a " <> context_type

      true ->
        "acted on a " <> context_type
    end
  end

  def activity_verb_object(%{verb: verb}) do
    verb <> " something"
  end

  def activity_verb_object(%{context_type: context_type}) do
    "did " <> context_type
  end

  def activity_verb_object(_) do
    "did something"
  end
end
