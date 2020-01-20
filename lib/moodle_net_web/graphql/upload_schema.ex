# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.UploadResolver

  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.Comment
  alias MoodleNet.Users.User

  import_types Absinthe.Plug.Types

  object :upload_mutations do
    @desc "Upload a small icon, also known as an avatar."
    field :upload_icon, type: :file_upload do
      arg(:context_id, non_null(:id))
      arg(:upload, non_null(:upload))
      resolve(&UploadResolver.upload_icon/2)
    end

    @desc "Upload a large image, also known as a header."
    field :upload_image, type: :file_upload do
      arg(:context_id, non_null(:id))
      arg(:upload, non_null(:upload))
      resolve(&(UploadResolver.upload_image/2))
    end

    field :upload_resource, type: :file_upload do
      arg(:context_id, non_null(:id))
      arg(:upload, non_null(:upload))
      resolve(&UploadResolver.upload_resource/2)
    end
  end

  @desc "An uploaded file, may contain metadata."
  object :file_upload do
    field(:id, non_null(:id))
    field(:url, non_null(:string))
    field(:size, non_null(:integer))
    field(:media_type, non_null(:string))
    field(:metadata, :file_metadata)

    field(:is_public, non_null(:boolean)) do
      resolve(&UploadResolver.is_public/3)
    end

    field(:parent, non_null(:upload_parent)) do
      resolve(&UploadResolver.parent/3)
    end

    field(:uploader, non_null(:user)) do
      resolve(&UploadResolver.uploader/3)
    end
  end

  @desc """
  Metadata associated with a file.

  None of the parameters are required and are filled depending on the
  file type.
  """
  object :file_metadata do
    field(:intrinsics, :file_intrinsics)
    # Image/Video
    field(:width_px, :integer)
    field(:height_px, :integer)
    # Audio
    field(:sample_rate_hz, :integer)
    field(:num_audio_channels, :integer)
  end

  @desc "More detailed metadata parsed from a file."
  object :file_intrinsics do
    # Audio
    field(:num_frames, :integer)
    field(:bits_per_sample, :integer)
    field(:byte_rate, :integer)
    field(:block_align, :integer)
    # Document
    field(:page_count, :integer)
    # Image
    field(:num_color_palette, :integer)
    field(:color_planes, :integer)
    field(:bits_per_pixel, :integer)
  end

  @desc "Supported parents of a file upload."
  union :upload_parent do
    description "A parent of an upload"
    types [:collection, :comment, :community, :resource, :user]
    resolve_type fn
      %Collection{}, _ -> :collection
      %Comment{},    _ -> :comment
      %Community{},  _ -> :community
      %Resource{},   _ -> :resource
      %User{},       _ -> :user
    end
  end
end
