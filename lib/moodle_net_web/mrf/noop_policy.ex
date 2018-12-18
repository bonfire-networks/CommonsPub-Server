defmodule ActivityPubWeb.MRF.NoOpPolicy do
  @behaviour ActivityPubWeb.MRF

  @impl true
  def filter(object) do
    {:ok, object}
  end
end
