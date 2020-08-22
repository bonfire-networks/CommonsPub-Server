# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonSchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.CommonResolver

  object :common_queries do
  end

  object :common_mutations do
    @desc "Delete more or less anything"
    field :delete, :any_context do
      arg(:context_id, non_null(:string))
      resolve(&CommonResolver.delete/2)
    end
  end

  @desc "Cursors for pagination"
  object :page_info do
    field(:start_cursor, list_of(non_null(:cursor)))
    field(:end_cursor, list_of(non_null(:cursor)))
    field(:has_previous_page, :boolean)
    field(:has_next_page, :boolean)
  end
end
