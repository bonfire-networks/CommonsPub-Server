defmodule MoodleNet.Communities.Members do

  import Ecto.Query
  alias MoodleNet.Communities.{Member, Members}

  @sortable_fields [:inserted_at]
  @default_ordering [desc_nulls_last: :inserted_at]

  # To correctly list, we must know whether the user is a community or
  # instance admin, in which case we should show private memberships,
  # otherwise only public memberships and that user will be shown
  
  def list(ordering \\ @default_ordering, pagination_opts),
    do: Repo.all(list_q(ordering, pagination_opts))
    
  def list_q(ordering \\ @default_ordering, pagination_opts) do
    Member
    |> Ectil.filter_private()                   # privacy
    |> ordered(ordering)               # determinism
    |> Ectil.paginate(pagination_opts) # size reduction
  end

  defp ordered(query, ordering \\ @default_ordering),
    do: Ectil.order_by([member], @sortable_fields, ordering)
      
  defp only_public(query),
    do: Query.where([member], member.is_public == true)

  def filter_q(query, %User{id: id}),
    do: Query.where(query, [member], member.user_id == ^id)

  def filter_q(query, %Community{id: id}),
    do: Query.where(query, [member], member.community_id == ^id)

end
