defmodule MoodleNetWeb.GraphQL.UploadSchema do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.UploadResolver

  import_types Absinthe.Plug.Types

  object :upload_mutations do
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
end
