defmodule ActivityPub.Utils do
  @moduledoc """
  Misc functions used for federation
  """
  alias ActivityPub.Keys

  def ensure_keys_present(actor) do
    if actor.keys do
      {:ok, actor}
    else
      {:ok, pem} = Keys.generate_rsa_pem()

      ActivityPub.update(actor, %{keys: pem})
    end
  end
end
