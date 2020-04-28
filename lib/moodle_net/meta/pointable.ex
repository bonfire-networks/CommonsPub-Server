import ProtocolEx
defprotocol_ex MoodleNet.Meta.Pointable do
  @doc """
  In order to be able to point to something, we must know how to query
  it. This is the sidekick to Pointer.
  """
  def queries_module(self)
  def extra_filters(self), do: []
end

