# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
alias MoodleNet.GraphQL
alias MoodleNet.GraphQL.{Edge, EdgeList, NodeList, PageInfo, Response}
alias MoodleNet.Activities.Activity
alias MoodleNet.Collections.Collection
alias MoodleNet.Blocks.Block
alias MoodleNet.Flags.Flag
alias MoodleNet.Follows.Follow
alias MoodleNet.Features.Feature
alias MoodleNet.Likes.Like
alias MoodleNet.Tags.{Tag, Tagging}
alias MoodleNet.Threads.{Comment, Thread}
alias MoodleNet.Communities.Community
alias MoodleNet.Localisation.{Country, Language}
alias MoodleNet.Resources.Resource
alias MoodleNet.Users.{AuthPayload, Me, User}

# Activities

defimpl Response, for: Activity do
  def to_response(self, _info, _path) do
    self
  end
end

# Common

defimpl Response, for: Category do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, true) # lies
    # |> Map.put(:is_public, true) # lies
  end
end

defimpl Response, for: Flag do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, true) # lies
    # |> Map.put(:is_public, not is_nil(self.published_at))
    # |> Map.put(:is_resolved, not is_nil(self.resolved_at))
  end
end

defimpl Response, for: Follow do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, true) # lies
    # |> Map.put(:is_public, not is_nil(self.published_at))
  end
end

defimpl Response, for: Like do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, true) # lies
    # |> Map.put(:is_public, not is_nil(self.published_at))
  end
end

defimpl Response, for: Tag do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, true) # lies
    # |> Map.put(:is_public, true) # lies
  end
end

defimpl Response, for: Tagging do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, true) # lies
    # |> Map.put(:is_public, not is_nil(self.published_at))
  end
end

# Collections

defimpl Response, for: Collection do
  def to_response(self, _info, _path) do
    # actor = Map.take(self.actor, ~w(preferred_username canonical_url signing_key))
    self
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
    # |> Map.put(:is_hidden, not is_nil(self.hidden_at))
  end
end

# Comments

defimpl Response, for: Comment do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
    # |> Map.put(:is_hidden, not is_nil(self.hidden_at))
  end
end

defimpl Response, for: Thread do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
    # |> Map.put(:is_hidden, not is_nil(self.hidden_at))
  end
end

# Common
defimpl Response, for: Like do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
  end
end
defimpl Response, for: Flag do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
    # |> Map.put(:is_hidden, not is_nil(self.hidden_at))
  end
end
defimpl Response, for: Follow do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
  end
end
# defimpl Response, for: Tagging do
#   def to_response(self, _info, _path) do
#     self
#     |> Map.put(:is_local, is_nil(self.actor.peer_id))
#     |> Map.put(:is_public, not is_nil(self.published_at))
#     |> Map.put(:is_hidden, not is_nil(self.hidden_at))
#   end
# end

# Communities

defimpl Response, for: Community do
  def to_response(self, _info, _path) do
    # actor = Map.take(self.actor, ~w(preferred_username canonical_url signing_key))
    self
    # |> Map.merge(actor)
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
    # |> Map.put(:is_disabled, not is_nil(self.disabled_at))
  end
end

# GraphQL

defimpl Response, for: Edge do
  def to_response(self, _info, _path), do: self
end
defimpl Response, for: EdgeList do
  def to_response(self, _info, _path), do: self
end
defimpl Response, for: NodeList do
  def to_response(self, _info, _path), do: self
end
defimpl Response, for: PageInfo do
  def to_response(self, _info, _path), do: self
end

# Localisation

defimpl Response, for: Country do
  def to_response(self, _info, _path), do: self
end

defimpl Response, for: Language do
  def to_response(self, _info, _path), do: self
end

# Resources

defimpl Response, for: Resource do
  def to_response(self, _info, _path) do
    self
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
    # |> Map.put(:is_hidden, not is_nil(self.hidden_at))
  end
end

# Users

defimpl Response, for: AuthPayload do
  def to_response(self, _info, path) do
    # actor = Map.take(self.actor, ~w(preferred_username canonical_url signing_key))
    self
  end
end

defimpl Response, for: Me do
  @me_fields ~w(email wants_email_digest wants_notifications is_confirmed is_instance_admin)a
  def to_response(self, info, path), do: self
    # user = Response.to_response(self.user, info, path ++ [:user])
    # ret = self.user.local_user
    # |> Map.take(@me_fields)
    # |> Map.put(:user, user)
    # IO.inspect(ret: ret)
    # ret
  # end
end

defimpl Response, for: User do
  def to_response(self, _info, path) do
    # actor = Map.take(self.actor, ~w(preferred_username canonical_url signing_key))
    self
    # |> Map.merge(actor)
    # |> Map.put(:is_local, is_nil(self.actor.peer_id))
    # |> Map.put(:is_public, not is_nil(self.published_at))
    # |> Map.put(:is_disabled, not is_nil(self.disabled_at))
  end
end

# Builtins

defimpl Response, for: BitString do
  def to_response(val,_,_), do: val
end
defimpl Response, for: DateTime do
  def to_response(val,_,_), do: val
end
defimpl Response, for: Integer do
  def to_response(val,_,_), do: val
end
defimpl Response, for: Float do
  def to_response(val,_,_), do: val
end
defimpl Response, for: Nil do
  def to_response(_,_,_), do: nil
end
defimpl Response, for: Atom do
  def to_response(true,_,_), do: true
  def to_response(false,_,_), do: false
  def to_response(atom,_,_), do: Atom.to_string(atom)
end
defimpl Response, for: Map do
  def to_response(self, info, path) do
    self
    |> Enum.reduce(%{}, fn {k,v}, acc ->
      Map.put(acc, k, MoodleNet.GraphQL.response(v, info, path ++ [k]))
    end)
  end
end

defimpl Response, for: List do
  def to_response(self, info, path) do
    Enum.map(self, &MoodleNet.GraphQL.response(&1, info, path))
  end
end

