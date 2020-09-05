# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Collections.CollectionFollowerCount do
  use CommonsPub.Common.Schema
  alias CommonsPub.Collections.Collection

  view_schema "mn_collection_follower_count" do
    belongs_to(:collection, Collection, primary_key: true)
    field(:count, :integer)
  end
end
