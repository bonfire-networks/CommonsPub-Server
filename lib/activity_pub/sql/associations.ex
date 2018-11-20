defmodule ActivityPub.SQL.ObjectToObjectAssoc do
  use Ecto.Schema
  alias ActivityPub.SQLObject

  schema "abstract table: object_to_object" do
    belongs_to(:subject, SQLObject, references: :local_id) 
    belongs_to(:object, SQLObject, references: :local_id) 

    timestamps(updated_at: false)
  end
end
