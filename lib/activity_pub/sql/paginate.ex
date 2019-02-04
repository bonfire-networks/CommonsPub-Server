defmodule ActivityPub.SQL.Paginate do
  import Ecto.Query

  def by_local_id(query, params) do
    params = normalize_params(params)

    query
    |> select_cursor()
    |> where(^dynamic_where(params))
    |> limit(^params[:limit])
    |> order_by([entity: entity], [{^params[:order], entity.local_id}])
  end

  def by_collection_insert(query, params) do
    params = normalize_params(params)

    query
    |> collection_select_cursor()
    |> where(^collection_dynamic_where(params))
    |> limit(^params[:limit])
    |> order_by([..., c], [{^params[:order], c.id}])
  end

  defp normalize_params(query_params) do
    query_params = Enum.into(query_params, %{})

    %{
      limit: calc_limit(query_params),
      after: query_params[:after] || query_params["after"],
      before: query_params[:before] || query_params["before"]
    }
    |> calc_order()
  end

  defp calc_limit(query_params) do
    Enum.min([query_params[:limit] || query_params["limit"] || 20, 100])
  end

  defp calc_order(%{after: nil, before: cursor} = params) when not is_nil(cursor),
    do: Map.put(params, :order, :asc)

  defp calc_order(params),
    do: Map.put(params, :order, :desc)

  defp select_cursor(query) do
    from([entity: entity] in query, select_merge: %{cursor: entity.local_id})
  end

  defp dynamic_where(query_params) do
    true
    |> after_filter(query_params)
    |> before_filter(query_params)
  end

  defp after_filter(dynamic, %{after: nil}), do: dynamic

  defp after_filter(dynamic, %{after: id}) when not is_nil(id) do
    dynamic([entity: entity], entity.local_id < ^id and ^dynamic)
  end

  defp before_filter(dynamic, %{before: nil}), do: dynamic

  defp before_filter(dynamic, %{before: id}) do
    dynamic([entity: entity], entity.local_id > ^id and ^dynamic)
  end

  defp collection_select_cursor(query) do
    from([..., col] in query, select_merge: %{cursor: col.id})
  end

  defp collection_dynamic_where(query_params) do
    true
    |> collection_after_filter(query_params)
    |> collection_before_filter(query_params)
  end

  defp collection_after_filter(dynamic, %{after: nil}), do: dynamic

  defp collection_after_filter(dynamic, %{after: id}) when not is_nil(id) do
    dynamic([..., c], c.id < ^id and ^dynamic)
  end

  defp collection_before_filter(dynamic, %{before: nil}), do: dynamic

  defp collection_before_filter(dynamic, %{before: id}) do
    dynamic([..., c], c.id > ^id and ^dynamic)
  end

  def meta(values, params) do
    params = normalize_params(params)

    %{
      newer: calc_newer_page(params, values),
      older: calc_older_page(params, values)
    }
  end

  def with_meta(values, query_params) do
    {values, meta(query_params, values)}
  end

  defp calc_newer_page(%{order: :asc, limit: limit}, values) when length(values) < limit,
    do: nil
  defp calc_newer_page(%{order: :asc, limit: limit}, values) when length(values) >= limit,
    do: List.last(values).cursor
  defp calc_newer_page(%{order: :desc, after: nil}, _), do: nil
  defp calc_newer_page(%{order: :desc, after: id}, []), do: id - 1
  defp calc_newer_page(%{order: :desc}, [entity | _]),
    do: entity.cursor


  defp calc_older_page(%{order: :desc, limit: limit}, values) when length(values) < limit,
    do: nil
  defp calc_older_page(%{order: :desc, limit: limit}, values) when length(values) >= limit,
    do: List.last(values).cursor
  defp calc_older_page(%{order: :asc, before: nil}, _), do: nil
  defp calc_older_page(%{order: :asc, before: id}, []), do: id + 1
  defp calc_older_page(%{order: :asc}, [entity | _]), do: entity.cursor
end
