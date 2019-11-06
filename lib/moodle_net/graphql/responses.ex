alias MoodleNet.GraphQL
alias MoodleNet.GraphQL.Response
alias MoodleNet.Actors.Actor
alias MoodleNet.Communities.Community
alias MoodleNet.Localisation.{Country, Language}
alias MoodleNet.Users.User
# Actors

defimpl Response, for: Actor do
  def to_response(self, info, path) do
    self.current
    |> Map.merge(self)
    |> Map.take(GraphQL.wanted(info, path))
    |> Map.put(:local, is_nil(self.peer_id))
  end
end

# Communities

defimpl Response, for: Community do
  def to_response(self, info, path) do
    self
    |> Map.merge(self.actor.current)
    |> Map.merge(self.actor)
    |> Map.take(GraphQL.wanted(info, path))
    |> Map.put(:local, is_nil(self.actor.peer_id))
  end
end

# Localisation

defimpl Response, for: Country do
  def to_response(self, info, path),
    do: Map.take(self, GraphQL.wanted(info, path))
end

defimpl Response, for: Language do
  def to_response(self, info, path),
    do: Map.take(self, GraphQL.wanted(info, path))
end

# Users

# defimpl Response, for: User do
#   def to_response(self, info, path) do
#     self
#     |> Map.merge(self.actor.current)
#     |> Map.merge(self.actor)
#     |> Map.take(GraphQL.wanted(info, path))
#     |> Map.put(:local, is_nil(self.actor.peer_id))
#   end
# end

# Builtins

defimpl Response, for: Map do
  def to_response(self, info, path),
    do: Map.take(self, GraphQL.wanted(info, path))
end

