defmodule MoodleNetWeb.Helpers.Discussions do
  alias MoodleNet.{
    Repo
  }

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Helpers.{Profiles}

  def prepare_comments(comments, current_user) do
    Enum.map(
      comments,
      &prepare_comment(&1, current_user)
    )
  end

  def prepare_comment(%MoodleNet.Threads.Comment{} = comment, current_user) do
    comment = maybe_preload(comment, :creator)

    creator = Profiles.prepare(comment.creator, %{icon: true, actor: true})

    {:ok, from_now} =
      Timex.shift(comment.published_at, minutes: -3)
      |> Timex.format("{relative}", :relative)

    comment
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})
    |> Map.merge(%{comments: []})
  end

  def prepare_comment(comment, _) do
    IO.inspect("comment already prepared")
    comment
  end

  def prepare_thread(thread, with_context) do
    thread =
      if(!is_nil(thread.context_id)) do
        {:ok, pointer} = MoodleNet.Meta.Pointers.one(id: thread.context_id)
        context = MoodleNet.Meta.Pointers.follow!(pointer)
        IO.inspect(context, label: "COPNTEXT")
        context =
          Profiles.prepare(
            context,
            %{
              icon: true,
              image: true
            },
            150
          )

        thread
        |> Map.merge(%{context: context})
      else
        thread
      end

    prepare_thread(thread)
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


    thread = maybe_preload(thread, :creator)

    creator = Profiles.prepare(thread.creator, %{icon: true, actor: true})


    {:ok, from_now} =
      Timex.shift(thread.published_at, minutes: -3)
      |> Timex.format("{relative}", :relative)

    thread
    |> Map.merge(%{published_at: from_now})
    |> Map.merge(%{creator: creator})

  end

  def build_comment_tree(comments) do
    comments =
      comments
      |> Enum.reverse()
      |> Enum.map(&Map.from_struct/1)

    lum = Enum.reduce(comments, %{}, &Map.put(&2, &1.id, &1))

    # IO.inspect(lum)

    comments
    |> Enum.reduce(lum, fn
      %{reply_to_id: nil} = comment, acc ->
        acc

      comment, acc ->
        # IO.inspect(acc: acc)
        # IO.inspect(comment: comment)

        acc
        |> update_in([comment.reply_to_id, :comments], &[acc[comment.id] | &1])
        |> Map.delete(comment.id)
    end)
  end
end
