defmodule ActivityPub.Guards do
  alias ActivityPub.Metadata.Guards, as: APMG
  require APMG

  defguard is_entity(e) when APMG.is_metadata(:erlang.map_get(:__ap__, e))
  defguard has_type(e, type) when APMG.has_type(:erlang.map_get(:__ap__, e), type)
  defguard has_aspect(e, aspect) when APMG.has_aspect(:erlang.map_get(:__ap__, e), aspect)


  defguard is_activity(e)
           when is_entity(e) and
                  :erlang.map_get(:is_activity, :erlang.map_get(:metadata, e)) == true

  defguard is_follow(e)
           when is_entity(e) and
                  :erlang.map_get(:is_follow, :erlang.map_get(:metadata, e)) == true

  defguard is_actor(e)
           when is_entity(e) and :erlang.map_get(:is_actor, :erlang.map_get(:metadata, e)) == true

  defguard is_moodle_net_community(e)
           when is_entity(e) and
                  :erlang.map_get(:is_moodle_net_community, :erlang.map_get(:metadata, e)) == true

  defguard is_moodle_net_collection(e)
           when is_entity(e) and
                  :erlang.map_get(:is_moodle_net_collection, :erlang.map_get(:metadata, e)) ==
                    true

  defguard is_moodle_net_educational_resource(e)
           when is_entity(e) and
                  :erlang.map_get(
                    :is_moodle_net_educational_resource,
                    :erlang.map_get(:metadata, e)
                  ) == true
end
