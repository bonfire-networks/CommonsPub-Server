defmodule ActivityPub.Guards do
  alias ActivityPub.Metadata.Guards, as: APMG
  require APMG

  defguard is_entity(e) when APMG.is_metadata(:erlang.map_get(:__ap__, e))
  defguard is_local(e) when APMG.is_local(:erlang.map_get(:__ap__, e))
  defguard has_type(e, type) when APMG.has_type(:erlang.map_get(:__ap__, e), type)
  defguard has_aspect(e, aspect) when APMG.has_aspect(:erlang.map_get(:__ap__, e), aspect)
  defguard has_status(e, status) when APMG.has_status(:erlang.map_get(:__ap__, e), status)
  defguard has_local_id(e) when APMG.has_local_id(:erlang.map_get(:__ap__, e))

  defmacro status(e) do
    quote bind_quoted: [e: e] do
      :erlang.map_get(:status, :erlang.map_get(:meta, e))
    end
  end

end
