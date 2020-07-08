defmodule MoodleNetWeb.Helpers.Discussion do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def prepare_comment(comment) do
    comment = Repo.preload(comment, :creator)

    creator = Profiles.prepare(comment.creator, %{icon: true, actor: true})

    {:ok, from_now} =
      Timex.shift(comment.published_at, minutes: -3)
      |> Timex.format("{relative}", :relative)

    comment
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})
  end

  def prepare_thread(thread) do
    thread =
      if(!is_nil(thread.context_id)) do
        {:ok, pointer} = MoodleNet.Meta.Pointers.one(id: thread.context_id)
        context = MoodleNet.Meta.Pointers.follow!(pointer)

        thread
        |> Map.merge(%{context: context})
      else
        thread
      end

    thread = Repo.preload(thread, :creator)

    creator = Profiles.prepare(thread.creator, %{icon: true, actor: true})

    {:ok, from_now} =
      Timex.shift(thread.published_at, minutes: -3)
      |> Timex.format("{relative}", :relative)

    thread
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})
  end
end
