defmodule ActivityPub.SQL.AssociationNotLoaded do
  @moduledoc """
  When an aspect is not loaded in an entity, all the association fields are set to this struct.
  """
  @enforce_keys [:sql_assoc, :sql_aspect]
  defstruct sql_assoc: nil, sql_aspect: nil, local_id: nil
end
