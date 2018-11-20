defmodule ActivityPub.Guards do
  defguard is_entity(e) when :erlang.map_get(:__struct__, e) == ActivityPub.Entity

  # for type <- ActivityPub.Types.all() do
  #   field = ActivityPub.Metadata.Helper.from_type_to_field(type)
  #   defguard unquote(field)(e) when :erlang.map_get(unquote(field), :erlang.map_get(:metadata, e)) == true
  # end

  defguard is_activity(e) when is_entity(e) and :erlang.map_get(:is_activity, :erlang.map_get(:metadata, e)) == true
  defguard is_follow(e) when is_entity(e) and :erlang.map_get(:is_follow, :erlang.map_get(:metadata, e)) == true
  defguard is_actor(e) when is_entity(e) and :erlang.map_get(:is_actor, :erlang.map_get(:metadata, e)) == true
end
