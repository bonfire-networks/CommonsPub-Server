defmodule MoodleNet.Resources.Resource do

  use Ecto.Schema
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Collections.Collection

  schema "mn_resource" do
    belongs_to :creator, Actor
    belongs_to :collection, Collection
    field :content, :string
    field :primary_language, :string
    field :url, :string
    field :same_as, :string
    field :free_access, :boolean
    field :public_access, :boolean
    field :license, :string
    field :learning_resource_type, :string
    field :educational_use, {:array, :string}
    field :time_required, :integer
    field :typical_age_range, :string
    timestamps()
  end

end
