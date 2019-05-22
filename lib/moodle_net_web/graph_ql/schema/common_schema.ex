defmodule MoodleNetWeb.GraphQL.CommonSchema do
  @moduledoc """
  Common schemas fields. Node is not used.
  """
  use Absinthe.Schema.Notation

  interface :node do
    field(:id, non_null(:id))
    field(:type, non_null(list_of(non_null(:string))))
    field(:name, :string)
  end

  object :page_info do
    field(:start_cursor, :integer)
    field(:end_cursor, :integer)
  end
end
