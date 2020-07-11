defmodule MoodleNetWeb.My.Publish.WriteLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common
  # alias MoodleNetWeb.Helpers.{Profiles, Account}
  # alias MoodleNetWeb.Component.HeaderLive

  # terminate tags with space
  @tag_terminator " "

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       title_placeholder: "An optional title...",
       summary_placeholder: "Write a story or get a discussion started!",
       post_label: "Publish",
       #  current_user: Account.current_user_or(nil, session, %{icon: true, actor: true}),
       meili_host: System.get_env("SEARCH_MEILI_INSTANCE", "localhost:7700"),
       tag_search: nil,
       tag_results: [],
       tag_target: ""
     )}
  end

  def handle_event("tag_suggest", %{"content" => content}, socket)
      when byte_size(content) >= 1 do
    IO.inspect(tag_suggest: content)

    tag_search = tag_prepare(content)

    if tag_search do
      tag_results = tag_autocomplete(tag_search)

      IO.inspect(tag_results: tag_results)

      {:noreply,
       assign(socket,
         tag_search: tag_search,
         # ID of the input, TODO: handle several inputs
         tag_target: "content",
         tag_results: tag_results
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("tag_suggest", data, socket) do
    IO.inspect(ignore_tag_suggest: data)

    {:noreply,
     assign(socket,
       tag_search: "",
       tag_results: []
     )}
  end

  def handle_event("post", %{"content" => content} = data, socket) do
    IO.inspect(data, label: "DATA")

    if(is_nil(content) or is_nil(socket.assigns.current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please write something...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)

      comment = input_to_atoms(data)

      thread =
        MoodleNetWeb.GraphQL.ThreadsResolver.create_thread(
          %{comment: comment},
          %{context: %{current_user: socket.assigns.current_user}}
        )

      {:noreply,
       socket
       |> put_flash(:info, "Published!")
       # change redirect
       |> redirect(to: "/«" <> thread.id)}
    end
  end

  def tag_prepare(text) do
    parts = String.split(text, "+")

    if length(parts) > 1 do
      List.last(parts)
    end
  end

  def tag_autocomplete(tag_search) do
    if String.length(tag_search) > 0 and String.length(tag_search) < 20 and
         !(tag_search =~ @tag_terminator) do
      Search.Meili.search(tag_search)
      # {words, _} = System.cmd("grep", ~w"^#{tag_search}.* -m 5 /usr/share/dict/words")
      # String.split(words, "\n")
    else
      []
    end
  end

  def tag_suggestion_display(hit, tag_search) do
    [head | tail] = String.split(e(hit, "name", ""), tag_search)
    List.to_string([head, "<span>", tag_search, "</span>", tail])
  end
end
