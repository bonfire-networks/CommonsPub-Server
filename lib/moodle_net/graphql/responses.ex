alias MoodleNet.GraphQL
alias MoodleNet.GraphQL.Response
alias MoodleNet.Actors.Actor

defimpl Response, for: Actor do
  def to_response(self, info, path) do
    self.current
    |> Map.merge(self)
    |> Map.take(GraphQL.wanted(info, path))
    |> Map.put(:local, is_nil(self.peer_id))
  end
end

defimpl Response, for: Map do
  def to_response(self, info, path),
    do: Map.take(self, GraphQL.wanted(info, path))
end
