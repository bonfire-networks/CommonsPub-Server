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
    @desc "Upload an avatar (icon in ActivityPub)"
    field :upload_icon, type: :string do
      arg(:local_id, non_null(:integer))
      arg(:image, non_null(:upload))
      resolve(&UploadResolver.upload_icon/2)
    end

    @desc "Upload a background image (image in ActivityPub)"
    field :upload_image, type: :string do
      arg(:local_id, non_null(:integer))
      arg(:image, non_null(:upload))
      resolve(&UploadResolver.upload_image/2)
    end
  end

  object :icon do
    field(:url, non_null(:string))
    field(:media_type, :string)
    field(:width, :integer)
    field(:height, :integer)
    field(:preview, :preview)
  end

  object :preview do
    field(:url, non_null(:string))
    field(:media_type, :string)
    field(:width, :integer)
    field(:height, :integer)
  end
end
