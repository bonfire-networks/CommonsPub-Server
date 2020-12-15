defmodule CommonsPub.Tag.Autocomplete do
  use CommonsPub.Web, :controller

  # TODO: consolidate CommonsPub.Tag.Autocomplete and CommonsPub.Web.Component.TagAutocomplete

  def get(conn, %{"prefix" => prefix, "search" => search, "consumer" => consumer}) do
    tags = tag_lookup(search, prefix, consumer)

    json(conn, tags)
  end

  def get(conn, %{"prefix" => prefix, "search" => search}) do
    tags = tag_lookup(search, prefix, "tag_as")

    json(conn, tags)
  end

  def tag_lookup(tag_search, "+" = prefix, consumer) do
    tag_lookup_public(tag_search, prefix, consumer, ["Collection", "Category", "Taggable"])
  end

  def tag_lookup(tag_search, "@" = prefix, consumer) do
    tag_lookup_public(tag_search, prefix, consumer, "User")
  end

  def tag_lookup(tag_search, "&" = prefix, consumer) do
    tag_lookup_public(tag_search, prefix, consumer, "Community")
  end

  def tag_lookup_public(tag_search, prefix, consumer, index_type) do
    search = Bonfire.Search.search(tag_search, nil, false, %{"index_type" => index_type})
    IO.inspect(search)
    tag_lookup_process(tag_search, search, prefix, consumer)
  end

  def tag_lookup_process(tag_search, search, prefix, consumer) do
    if(Map.has_key?(search, "hits") and length(search["hits"])) do
      # IO.inspect(search["hits"])
      hits = Enum.map(search["hits"], &tag_hit_prepare(&1, tag_search, prefix, consumer))
      Enum.filter(hits, & &1)
    end
  end

  def tag_hit_prepare(hit, _tag_search, prefix, consumer) do
    # IO.inspect(consumer)
    # IO.inspect(Map.new(consumer: "test"))

    # FIXME: do this by filtering Meili instead?
    if strlen(hit["username"]) > 0 or (prefix == "+" and strlen(hit["id"]) > 0) do
      hit
      |> Map.merge(%{
        "name" => e(hit, "name_crumbs", e(hit, "name", e(hit, "username", nil)))
      })
      |> Map.merge(%{
        "link" => e(hit, "canonical_url", "#unknown-hit-url")
      })
      |> tag_add_field(consumer, prefix, e(hit, "username", e(hit, "id", "")))
      |> Map.drop(["name_crumbs"])
    end
  end

  def tag_add_field(hit, "tag_as", _prefix, as) do
    Map.merge(hit, %{tag_as: as})
  end

  def tag_add_field(hit, "ck5", prefix, as) do
    if String.at(as, 0) == prefix do
      Map.merge(hit, %{"id" => to_string(as)})
    else
      Map.merge(hit, %{"id" => prefix <> to_string(as)})
    end
  end

  # def tag_suggestion_display(hit, tag_search) do
  #   name = e(hit, "name_crumbs", e(hit, "name", e(hit, "username", nil)))

  #   if !is_nil(name) and name =~ tag_search do
  #     split = String.split(name, tag_search, parts: 2, trim: false)
  #     IO.inspect(split)
  #     [head | tail] = split

  #     List.to_string([head, "<span>", tag_search, "</span>", tail])
  #   else
  #     name
  #   end
  # end
end
