defmodule ActivityPub.SQL.FieldNotLoaded do
  @moduledoc """
  When an aspect is not loaded in an entity, all the aspect fields are set to this struct.
  """
  defstruct []
end
