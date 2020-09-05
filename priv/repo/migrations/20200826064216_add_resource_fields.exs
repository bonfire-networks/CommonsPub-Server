defmodule CommonsPub.Repo.Migrations.AddResourceFields do
  use Ecto.Migration

  def change do
    alter table("mn_resource") do
      # @desc "The file type"
      add(:mime_type, :string)

      # @desc "The type of content that may be embeded"
      add(:embed_type, :string)

      # @desc "The HTML code of content that may be embeded"
      add(:embed_code, :text)

      # @desc "Can you use this without needing an account somewhere?"
      add(:public_access, :boolean)

      # @desc "Can you use it without paying?"
      add(:free_access, :boolean)

      # @desc "How can you access it? see https://www.w3.org/wiki/WebSchemas/Accessibility"
      add(:accessibility_feature, {:array, :string})
    end
  end
end
