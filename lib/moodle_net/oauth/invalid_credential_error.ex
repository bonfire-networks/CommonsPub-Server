defmodule MoodleNet.OAuth.InvalidCredentialError do
  defstruct []

  @type t :: %__MODULE__{}

  def new(), do: %__MODULE__{}
end
