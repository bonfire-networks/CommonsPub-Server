defmodule MoodleNetWeb.Helpers.Discussions do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.LikesResolver
  alias MoodleNetWeb.Helpers.{Profiles}

  def prepare_comments(comments, current_user) do
    Enum.map(
      comments,
      &prepare_comment(&1, current_user)
    )
  end

  def prepare_comment(comment, current_user) do
    comment = Repo.preload(comment, :creator)

    creator = Profiles.prepare(comment.creator, %{icon: true, actor: true})

    liked_bool = is_liked(current_user, comment.id)

    {:ok, from_now} =
      Timex.shift(comment.published_at, minutes: -3)
      |> Timex.format("{relative}", :relative)

    comment
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})
    |> Map.merge(%{is_liked: liked_bool})
    |> Map.merge(%{comments: []})
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
