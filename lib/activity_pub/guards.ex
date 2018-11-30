defmodule ActivityPub.Guards do
  alias ActivityPub.Metadata.Guards, as: APMG
  require APMG

  defguard is_entity(e) when APMG.is_metadata(:erlang.map_get(:__ap__, e))
  defguard has_type(e, type) when APMG.has_type(:erlang.map_get(:__ap__, e), type)
  defguard has_aspect(e, aspect) when APMG.has_aspect(:erlang.map_get(:__ap__, e), aspect)

end
