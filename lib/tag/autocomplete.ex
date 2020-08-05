defmodule CommonsPub.Tag.Autocomplete do
  use MoodleNetWeb, :controller

  import MoodleNetWeb.Helpers.Common

  def get(conn, %{"prefix" => prefix, "search" => search, "consumer" => consumer}) do
    tags = tag_lookup(search, prefix, consumer)

    json(conn, tags)
  end

  def get(conn, %{"prefix" => prefix, "search" => search}) do
    tags = tag_lookup(search, prefix, "tag_as")

    json(conn, tags)
  end

  def tag_lookup(tag_search, "+", consumer) do
    do_tag_lookup(tag_search, "taxonomy_tags", "+", consumer)
  end

  def tag_lookup(tag_search, prefix, consumer) do
    do_tag_lookup(tag_search, "public", prefix, consumer)
  end

  def do_tag_lookup(tag_search, index, prefix, consumer) do
    search = Search.Meili.search(tag_search, index)

    if(Map.has_key?(search, "hits") and length(search["hits"])) do
      # search["hits"]
      hits = Enum.map(search["hits"], &tag_hit_prepare(&1, tag_search, prefix, consumer))
      Enum.filter(hits, & &1)
    end
  end

  def tag_hit_prepare(hit, tag_search, prefix, consumer) do
    # IO.inspect(consumer)
    # IO.inspect(Map.new(consumer: "test"))

    # FIXME: do this by filtering Meili instead?
    if strlen(hit["preferredUsername"]) > 0 or (prefix == "+" and strlen(hit["id"]) > 0) do
      hit
      |> Map.merge(%{
        "name" => e(hit, "name_crumbs", e(hit, "name", e(hit, "preferredUsername", nil)))
      })
      |> Map.merge(%{
        "link" => e(hit, "canonicalUrl", "#unknown-hit-url")
      })
      |> tag_add_field(consumer, prefix, e(hit, "preferredUsername", e(hit, "id", "")))
      |> Map.drop(["name_crumbs"])
    end
  end

  def tag_add_field(hit, "tag_as", prefix, as) do
    Map.merge(hit, %{tag_as: as})
  end

  def tag_add_field(hit, "ck5", prefix, as) do
    Map.merge(hit, %{"id" => prefix <> to_string(as)})
  end

  # def tag_suggestion_display(hit, tag_search) do
  #   name = e(hit, "name_crumbs", e(hit, "name", e(hit, "preferredUsername", nil)))

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
