defmodule MoodleNetWeb.My.Publish.WriteLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.{Profiles, Account}
  alias MoodleNetWeb.Component.HeaderLive

  # terminate tags with char U+2000
  @tag_terminator " "

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(
       title_placeholder: "An optional title for your story or discussion",
       summary_placeholder: "Write a story or get a discussion started!",
       post_label: "Post",
       current_user: Account.current_user_or(nil, session, %{icon: true, actor: true}),
       meili_host: MoodleNet.Instance.hostname(),
       tag_search: nil,
       matches: [],
       tag_target: ""
     )}
  end

  def handle_event("tag_suggest", %{"content" => content}, socket)
      when byte_size(content) <= 100 do
    tag_search = tag_prepare(content)
    matches = tag_search(tag_search)

    {:noreply,
     assign(socket,
       tag_search: tag_search,
       # ID of the input, TODO: handle several inputs
       tag_target: "content",
       matches: matches
     )}
  end

  def handle_event("tag_suggest", data, socket) do
    IO.inspect(data)

    {:noreply,
     assign(socket,
       tag_search: "",
       matches: []
     )}
  end

  def tag_prepare(text) do
    parts = String.split(text, "+")

    if length(parts) > 1 do
      List.last(parts)
    else
      ""
    end
  end

  def tag_search(tag_search) do
    if String.length(tag_search) > 0 and String.length(tag_search) < 20 and
         !(tag_search =~ @tag_terminator) do
      {words, _} = System.cmd("grep", ~w"^#{tag_search}.* -m 5 /usr/share/dict/words")
      String.split(words, "\n")
    else
      []
    end
  end

  def tag_match(match, tag_search) do
    [head | tail] = String.split(match, tag_search)
    List.to_string([head, "<span>", tag_search, "</span>", tail])
  end

  def handle_event("tag_pick", %{"tag" => tag}, socket) do
    IO.inspect(tag)

    {:noreply,
     assign(socket,
       tag_search: "",
       matches: []
     )}
  end

  def handle_event("post", %{"content" => content} = data, socket) do
    IO.inspect(data, label: "DATA")

    if(is_nil(content) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please write something...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)

      comment = data |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

      thread =
        MoodleNet.Threads.create_with_comment(socket.assigns.current_user, %{comment: comment})

      {:noreply,
       socket
       |> put_flash(:info, "Published!")
       |> redirect(to: "/")}
    end
  end
end
