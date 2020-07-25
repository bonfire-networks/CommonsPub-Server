defmodule MoodleNetWeb.My.WriteLive do
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

  def handle_event("post", %{"content" => content} = data, socket) do
    IO.inspect(data, label: "POST DATA")

    if(is_nil(content) or is_nil(socket.assigns.current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please write something...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)

      comment = input_to_atoms(data)

      {:ok, thread} =
        MoodleNetWeb.GraphQL.ThreadsResolver.create_thread(
          %{comment: comment},
          %{context: %{current_user: socket.assigns.current_user}}
        )

      IO.inspect(thread, label: "THREAD")

      {:noreply,
       socket
       |> put_flash(:info, "Published!")
       # change redirect
       |> push_redirect(to: "/!" <> thread.thread_id)}
    end
  end

  def handle_event("tag_suggest", %{"content" => content}, socket)
      when byte_size(content) >= 1 do
    IO.inspect(tag_suggest: content)

    prefixes = ["@", "&", "+"]

    tries = Enum.map(prefixes, &try_tag_search(&1, content, socket))
    # IO.inspect(tries: tries)
    tries = Enum.filter(tries, & &1)
    found = List.first(tries)

    if(found) do
      {:noreply,
       assign(socket,
         # ID of the input, TODO: handle several inputs
         tag_target: "content",
         tag_search: found.tag_search,
         tag_prefix: found.tag_prefix,
         tag_results: found.tag_results
       )}
    else
      {:noreply, socket}
    end
  end

  def try_tag_search(tag_prefix, content, socket) do
    tag_search = tag_prepare(content, tag_prefix)

    if tag_search do
      do_tag_search(socket, tag_search, tag_prefix)
    end
  end

  def do_tag_search(socket, tag_search, tag_prefix) do
    tag_results = tag_lookup(tag_search, tag_prefix)

    IO.inspect(tag_prefix: tag_prefix)
    IO.inspect(tag_results: tag_results)

    if tag_results do
      %{tag_search: tag_search, tag_results: tag_results, tag_prefix: tag_prefix}
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

  def tag_prepare(text, prefix) do
    parts = String.split(text, prefix)

    if length(parts) > 1 do
      typed = List.last(parts)

      if String.length(typed) > 0 and String.length(typed) < 20 and
           !(typed =~ @tag_terminator) do
        typed
      end
    end
  end

  def tag_lookup(tag_search, "+") do
    do_tag_lookup(tag_search, "taxonomy_tags")
  end

  def tag_lookup(tag_search, _) do
    do_tag_lookup(tag_search, "public")
  end

  def do_tag_lookup(tag_search, index) do
    search = Search.Meili.search(tag_search, index)

    if(Map.has_key?(search, "hits") and length(search["hits"])) do
      search["hits"]
      # hits = Enum.map(search["hits"], &tag_hit_prepare/1)
      # Enum.filter(hits, & &1)
    end
  end

  def tag_hit_prepare(hit) do
    # FIXME: do this by filtering Meili instead?
    if !is_nil(hit["preferredUsername"]) do
      hit
    end
  end

  def tag_suggestion_display(hit, tag_search) do
    name = e(hit, "name", e(hit, "label", e(hit, "preferredUsername", "")))

    if name =~ tag_search do
      split = String.split(name, tag_search, parts: 2, trim: false)
      IO.inspect(split)
      [head | tail] = split

      List.to_string([head, "<span>", tag_search, "</span>", tail])
    else
      name
    end
  end
end
