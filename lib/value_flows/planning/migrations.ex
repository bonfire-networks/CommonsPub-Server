defmodule ValueFlows.Planning.Migrations do
  use Ecto.Migration
  alias MoodleNet.Repo
  alias Ecto.ULID

  @meta_tables [] ++ ~w(vf_intent) 

  def change_intent do
    create table(:vf_intent) do

      add :name, :string
      add :note, :string

      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :image_id, references(:mn_content)

      # belongs_to(:provider, Pointer) # TODO - use pointer like context?
      # belongs_to(:receiver, Pointer)
      add :provider_id, references("mn_pointer", on_delete: :nilify_all)
      add :receiver_id, references("mn_pointer", on_delete: :nilify_all)
  
      add :available_quantity, references("measurement", on_delete: :nilify_all)
      add :resource_quantity, references("measurement", on_delete: :nilify_all)
      add :effort_quantity, references("measurement", on_delete: :nilify_all)

      add :resource_classified_as, {:array, :string} # array of URI
      
      # # belongs_to(:resource_conforms_to, ResourceSpecification)
      # # belongs_to(:resource_inventoried_as, EconomicResource)
  
      add :at_location_id, references(:geolocation)
  
      add :action_id, references(:vf_action)

      # optional community as scope
      add :community_id, references("mn_community", on_delete: :nilify_all)

      add :finished, :boolean, default: false
      # # field(:deletable, :boolean) # TODO - virtual field? how is it calculated?
  
      # belongs_to(:input_of, Process)
      # belongs_to(:output_of, Process)
  
      # belongs_to(:agreed_in, Agreement)
  
      # inverse relationships 
      # has_many(:published_in, ProposedIntent)
      # has_many(:satisfied_by, Satisfaction)

      add :has_beginning, :timestamptz
      add :has_end, :timestamptz
      add :has_point_in_time, :timestamptz
      add :due, :timestamptz

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end

  end

  def add_intent_pointer do
    tables = Enum.map(@meta_tables, fn name ->
        %{"id" => ULID.bingenerate(), "table" => name}
      end)
      {_, _} = Repo.insert_all("mn_table", tables)
      tables = Enum.reduce(tables, %{}, fn %{"id" => id, "table" => table}, acc ->
        Map.put(acc, table, id)
    end)

    for table <- @meta_tables do
        :ok = execute """
        create trigger "insert_pointer_#{table}"
        before insert on "#{table}"
        for each row
        execute procedure insert_pointer()
        """
    end
  end


end
