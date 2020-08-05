defmodule MoodleNetWeb.Component.TagAutocomplete do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  # TODO: put in config
  @tag_terminator " "
  @tags_seperator " "
  @prefixes ["@", "&", "+"]
  @taxonomy_prefix "+"
  @taxonomy_index "taxonomy_tags"
  @search_index "public"

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       meili_host: System.get_env("SEARCH_MEILI_INSTANCE", "http://localhost:7700"),
       tag_search: nil,
       tag_results: []
     )}
  end

  # need to alias some form posting events here to workaround having two events but one target on a form
  def handle_event("publish_ad", data, socket) do
    MoodleNetWeb.My.PublishAdLive.publish_ad(data, socket)
  end

  def handle_event("tag_suggest", %{"content" => content}, socket)
      when byte_size(content) >= 1 do
    IO.inspect(tag_suggest_content: content)

    found = try_prefixes(content)

    if(found) do
      {:noreply,
       assign(socket,
         tag_search: found.tag_search,
         tag_prefix: found.tag_prefix,
         tag_results: found.tag_results
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("tag_suggest", %{"tags" => tags}, socket)
      when byte_size(tags) >= 1 do
    IO.inspect(tag_suggest_tags: tags)

    found = try_tag_search(tags)

    if(found) do
      {:noreply,
       assign(socket,
         tag_search: found.tag_search,
         tag_prefix: @tags_seperator,
         tag_results: found.tag_results
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

  def try_prefixes(content) do
    # FIXME
    tries = Enum.map(@prefixes, &try_tag_search(&1, content))

    # IO.inspect(tries: tries)

    tries = Enum.filter(tries, & &1)

    List.first(tries)
  end

  def try_tag_search(tag_prefix, content) do
    tag_search = tag_search_from_text(content, tag_prefix)

    if strlen(tag_search) > 0 do
      tag_search(tag_search, tag_prefix)
    end
  end

  def try_tag_search(content) do
    tag_search = tag_search_from_tags(content)

    if strlen(tag_search) > 0 do
      tag_search(tag_search, @taxonomy_prefix)
    end
  end

  def tag_search(tag_search, tag_prefix) do
    tag_results = search_prefix(tag_search, tag_prefix)

    IO.inspect(tag_prefix: tag_prefix)

    # IO.inspect(tag_results: tag_results)

    if tag_results do
      %{tag_search: tag_search, tag_results: tag_results, tag_prefix: tag_prefix}
    end
  end

  def tag_search_from_text(text, prefix) do
    parts = String.split(text, prefix)

    if length(parts) > 1 do
      typed = List.last(parts)

      if String.length(typed) > 0 and String.length(typed) < 20 and
           !(typed =~ @tag_terminator) do
        typed
      end
    end
  end

  def tags_split(text) do
    parts = String.split(text, @tags_seperator)

    if length(parts) > 0 do
      parts
    end
  end

  def tag_search_from_tags(text) do
    parts = tags_split(text)

    if length(parts) > 0 do
      typed = List.last(parts)

      if String.length(typed) do
        typed
      end
    end
  end

  def search_prefix(tag_search, "+") do
    search_from_index(tag_search, @taxonomy_index)
  end

  def search_prefix(tag_search, _) do
    search_from_index(tag_search, @search_index)
  end

  def search_from_index(tag_search, index) do
    search = Search.Meili.search(tag_search, index)

    if(Map.has_key?(search, "hits") and length(search["hits"])) do
      # search["hits"]
      hits = Enum.map(search["hits"], &tag_hit_prepare(&1, tag_search))
      Enum.filter(hits, & &1)
    end
  end

  def tag_hit_prepare(hit, tag_search) do
    # FIXME: do this by filtering Meili instead?
    if !is_nil(hit["preferredUsername"]) or !is_nil(hit["id"]) do
      hit
      |> Map.merge(%{display: tag_suggestion_display(hit, tag_search)})
      |> Map.merge(%{tag_as: e(hit, "preferredUsername", e(hit, "id", ""))})
    end
  end

  def tag_suggestion_display(hit, tag_search) do
    name = e(hit, "name_crumbs", e(hit, "name", e(hit, "preferredUsername", nil)))

    if !is_nil(name) and name =~ tag_search do
      split = String.split(name, tag_search, parts: 2, trim: false)
      IO.inspect(split)
      [head | tail] = split

      List.to_string([head, "<span>", tag_search, "</span>", tail])
    else
      name
    end
  end
end
