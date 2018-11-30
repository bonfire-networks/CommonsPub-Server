defmodule ActivityPub.SQL.ObjectToObjectAssoc do
  use Ecto.Schema
  alias ActivityPub.SQLEntity

  schema "abstract table: object_to_object" do
    belongs_to(:subject, SQLEntity, references: :local_id) 
    belongs_to(:object, SQLEntity, references: :local_id) 

    timestamps(updated_at: false)
  end
end
