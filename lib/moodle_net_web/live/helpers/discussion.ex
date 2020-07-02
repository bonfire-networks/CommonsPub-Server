defmodule MoodleNetWeb.Helpers.Discussion do
  alias MoodleNet.{
    Repo,
    Meta.Pointers
  }

  alias MoodleNetWeb.Helpers.{Profiles}

  def prepare(thread) do
    thread =
      if(!is_nil(thread.context_id)) do
        {:ok, pointer} = Pointers.one(id: thread.context_id)
        context = Pointers.follow!(pointer)

        type =
          context.__struct__
          |> Module.split()
          |> Enum.at(-1)
          |> String.downcase()

        thread
        |> Map.merge(%{context_type: type})
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
