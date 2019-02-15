defmodule ActivityPub.SQL.Paginate do
  import Ecto.Query

  def call(query, params) do
    params = normalize_params(params)

    query
    |> where(^dynamic_where(params))
    |> limit(^params[:limit])
    |> order_by([entity: entity], [{^params[:order], entity.local_id}])
  end

  defp normalize_params(query_params) do
    query_params = Enum.into(query_params, %{})
    %{
      limit: calc_limit(query_params),
      order: calc_order(query_params),
      starting_after: query_params[:starting_after] || query_params["starting_after"],
      ending_before: query_params[:ending_before] || query_params["ending_before"]
    }
  end

  defp calc_limit(query_params) do
    Enum.min([query_params[:limit] || query_params["limit"] || 100, 100])
  end

  def calc_order(query_params) do
    (query_params[:order] || query_params["order"])
    |> case do
      value when value in ["asc", "desc"] -> String.to_atom(value)
      value when value in [:asc, :desc] -> value
      _ -> :desc
    end
  end

  defp dynamic_where(query_params) do
    true
    |> starting_after_filter(query_params)
    |> ending_before_filter(query_params)
  end

  defp starting_after_filter(dynamic, %{starting_after: nil}), do: dynamic

  defp starting_after_filter(dynamic, %{starting_after: id}) do
    dynamic([entity: entity], entity.local_id < ^id and ^dynamic)
  end

  defp ending_before_filter(dynamic, %{ending_before: nil}), do: dynamic

  defp ending_before_filter(dynamic, %{ending_before: id}) do
    dynamic([entity: entity], entity.local_id > ^id and ^dynamic)
  end

  def meta(query_params, values) do
    calc_prev_page(query_params, values)
    |> Map.merge(calc_next_page(query_params, values))
  end

  def with_meta(values, query_params) do
    {values, meta(query_params, values)}
  end

  defp calc_prev_page(_, []), do: %{}
  defp calc_prev_page(_, [%{local_id: id} | _]), do: %{previous_page: %{ending_before: id}}

  defp calc_next_page(%{limit: limit}, values) when length(values) >= limit,
    do: %{next_page: %{starting_after: List.last(values).local_id}}

  defp calc_next_page(_, _),
    do: %{}
end
