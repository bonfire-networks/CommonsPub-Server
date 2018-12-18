defmodule ActivityPub.SQL.AssociationNotLoaded do
  @enforce_keys [:sql_assoc, :sql_aspect]
  defstruct sql_assoc: nil, sql_aspect: nil, local_id: nil
end
