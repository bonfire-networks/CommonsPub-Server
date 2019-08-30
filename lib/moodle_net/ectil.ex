defmodule MoodleNet.Ectil do

  alias Ecto.Query

  @default_order [desc_nulls_last: :inserted_at]

  def filter_private(query,),
    do: Query.where(query, [it], it.is_public == true or it.user_id == ^user_id)

  def paginate(query, opts), do: throw :unimplemented
  
  def order_by(query, sortable_fields, ordering)
  when is_list(sortable_fields) do
    order = order_by_clause(ordering, sortable_fields)
    Query.order_by(query, ^order)
  end

  def order_by_clause(many, sortable_fields) when is_list(many),
    do: Enum.map(many, &order_by_item/1)
    
  def order_by_clause(one={_, _}, sortable_fields),
    do: order_by([one], sortable_fields)

  defp order_by_item({field, ordering}, sortable_fields)
  when is_keyword(field) do
    if field in sortable_fields,
      do: {ordering(ordering), field}
      else: throw {:unknown_sort_field, field} # better error
  end

  defp ordering(:asc), do: :asc_nulls_last
  defp ordering(:desc), do: :desc_nulls_last
  defp ordering(o), do: throw {:unknown_ordering, o} # better error


end
