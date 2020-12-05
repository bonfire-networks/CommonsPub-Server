# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Likes.LikerCount do
  use Bonfire.Repo.Schema
  alias Pointers.Pointer

  view_schema "mn_liker_count" do
    belongs_to(:context, Pointer, primary_key: true)
    field(:count, :integer)
  end
end
