# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Collections.CollectionLike do
  use Ecto.Schema
  alias MoodleNet.ActivityPug.Object
  alias Ecto.Changeset

  schema "mn_collection_likes" do
    belongs_to :liked_object, Object
    belongs_to :liking_object, Object
    timestamps()
  end

  @cast_attrs [:liked_object_id, :liking_object_id]
  @required_attrs [:liked_object_id, :liking_object_id]

  @unique_index :mn_collection_likes_once_index

  def changeset(attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.unique_constraint(:liking_object_id, name: @unique_index)
  end

end

# defmodule MoodleNet.Common.Likes do
#   def __using__(opts) do
#     schema = Keyword.fetch! opts, :schema # mn_collection_likes
#     suffix = Keyword.get opts, :index_suffix, "_once_index"
#     index = String.to_atom(schema <> suffix)
#     quote do
#       use Ecto.Schema
#       alias MoodleNet.ActivityPug.Object
#       alias Ecto.Changeset

#       schema unquote(schema) do
#         belongs_to :liked_object, Object
#         belongs_to :liking_object, Object
#         timestamps()
#       end

#       @cast [:liked_object_id, :liking_object_id]
#       @required @cast

#       @unique_index unquote(index)

#       def changeset(attrs) do
#         %__MODULE__{}
#         |> Changeset.cast(attrs, @cast)
#         |> Changeset.validate_required(@required)
#         |> Changeset.unique_constraint(:liking_object_id, name: @unique_index)
#       end
#     end
#   end
# end
