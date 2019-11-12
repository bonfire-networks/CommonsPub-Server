# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.UploadResolver

  import_types Absinthe.Plug.Types

  object :upload_mutations do
    # TODO: return icon
    @desc "Upload an avatar (icon in ActivityPub). Returns the full image."
    field :upload, type: :string do
      arg(:context_id, non_null(:id))
      arg(:upload, non_null(:upload))
      resolve(&UploadResolver.upload/2)
    end
  end

  # @desc "An image that can optionally contain a preview."
  # object :upload do
  #   field(:id, non_null(:id))
  #   field(:url, non_null(:string))
  #   field(:media_type, :string)
  #   field(:width, :integer)
  #   field(:height, :integer)
  #   field(:preview, :preview)
  # end
end
