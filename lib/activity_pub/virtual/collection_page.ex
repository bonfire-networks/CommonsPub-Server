defmodule ActivityPub.CollectionPage do
  import ActivityPub.Guards
  alias ActivityPub.SQL.Query
  defguardp is_local_collection(collection) when has_type(collection, "Collection") and is_local(collection)

  def new(collection, params \\ %{}) when is_local_collection(collection) do
    items = get_items(collection, params)
    page_info = MoodleNet.page_info(items, params)
    %{
      id: id(collection, params),
      type: "CollectionPage",
      part_of: collection,
      items: items,
      total_items: length(items),
      next: next_page(collection, page_info.older),
      prev: prev_page(collection, page_info.newer),
    }
    |> ActivityPub.new()
  end

  def id(collection, params \\ %{}) when is_local_collection(collection) do
    query =
      params
      |> Map.take(["before", "after", "limit"])
      |> query()

    collection.id <> "/page" <> query
  end

  defp query(params) when params == %{}, do: ""
  defp query(params), do: "?#{URI.encode_query(params)}"

  defp get_items(collection, params) do
    Query.new()
    |> Query.belongs_to(collection)
    |> Query.paginate_collection(params)
    |> Query.all()
  end

  defp next_page(_collection, nil), do: nil
  defp next_page(collection, cursor), do: id(collection, %{"after" => cursor})
  defp prev_page(_collection, nil), do: nil
  defp prev_page(collection, cursor), do: id(collection, %{"before" => cursor})
end
