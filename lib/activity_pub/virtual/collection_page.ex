defmodule ActivityPub.CollectionPage do
  @moduledoc """
  TODO - Not every _ActivityPub.Entity_ should be persisted in the database, for example, a _CollectionPage_ is ephemeral. They are continuously changing, so it does not make sense to store them in the database.

  To solve that, this module for a virtual `CollectionPage` has started being developed.   This is interesting for the ActivityPub API and to iterate through a Collection.

  A `CollectionPage` has the same `id` as the `Collection`, and can be queried by appending something like: `/page?query_params_for_pagination`

  So a `CollectionPage` can be built passing the `Collection` and the query params for pagination.
  """

  import ActivityPub.Guards
  alias ActivityPub.UrlBuilder
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

  def id(collection, params \\ %{}) when is_local_collection(collection),
    do: UrlBuilder.id({:page, ActivityPub.local_id(collection), params})

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
