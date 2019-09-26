defmodule MoodleNet.Resources.ResourceRevision do
  use MoodleNet.Common.Schema
  alias Ecto.Changeset
  alias MoodleNet.Resources.{Resource, ResourceRevision}

  standalone_schema "mn_resource_revision" do
    belongs_to(:resource, Resource)
    field(:content, :string)
    field(:url, :string)
    field(:same_as, :string)
    field(:free_access, :boolean)
    field(:public_access, :boolean)
    field(:license, :string)
    field(:learning_resource_type, :string)
    field(:educational_use, {:array, :string})
    field(:time_required, :integer)
    field(:typical_age_range, :string)
    timestamps(updated_at: false)
  end

  @create_cast ~w(content url same_as free_access public_access license learning_resource_type educational_use time_required typical_age_range)a

  def create_changeset(%Resource{} = resource, attrs) do
    %ResourceRevision{resource: resource}
    |> Changeset.cast(attrs, @create_cast)
  end
end
