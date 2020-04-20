defmodule Intent do

  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias Intent

  @type t :: %__MODULE__{}

  table_schema "vf_intents" do
    # belongs_to(:action, Action)
    field(:name, :string)
    field(:note, :string)
    has_one(:available_quantity, Measure)
    field(:deletable, :boolean)
    # belongs_to(:agreed_in, Agreement )
    # belongs_to(:atLocation, Geolocation)
    has_one(:resource_quantity, Measure)
    has_one(:effort_quantity, Measure)
    field(:has_beginning, :utc_datetime_usec)
    field(:has_end, :utc_datetime_usec)
    field(:has_point_in_time, :utc_datetime_usec)
    # belongs_to(:image, Content)
    # belongs_to(:input_of, Process)
    # belongs_to(:output_of, Process)
    # belongs_to(:provider, User)
    # belongs_to(:receiver, User)
    # belongs_to(:published_in, ProposedIntent)
    field(:resource_classified_as, {:array, :string})
    # belongs_to(:resource_conforms_to, ResourceSpecification)
    # belongs_to(:resource_inventoried_as, EconomicResource)
    # belongs_to(:satisfied_by, Satisfaction)
    field(:finished, :boolean, default: false)
    # belongs_to(:in_scope_of, Community)

    belongs_to(:actor, Actor)

    belongs_to(:inbox_feed, Feed, foreign_key: :inbox_id)
    belongs_to(:outbox_feed, Feed, foreign_key: :outbox_id)
    field(:follower_count, :any, virtual: true) # because it's keyed by pointer

    timestamps()
  end
  
  
  @required ~w(name is_public)a
  @cast @required ++ ~w(note mappable_address point alt is_disabled inbox_id outbox_id)a

  def create_changeset(
        %User{} = creator,
        %Community{} = community,
        %Actor{} = actor,
        attrs
      ) do
    %Geolocation{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      community_id: community.id,
      actor_id: actor.id,
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(%Geolocation{} = geolocation, attrs) do
    geolocation
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end
end
