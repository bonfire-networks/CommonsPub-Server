defmodule ActivityPubWeb.MRF.DropPolicy do
  require Logger
  @behaviour ActivityPubWeb.MRF

  @impl true
  def filter(object) do
    Logger.info("REJECTING #{inspect(object)}")
    {:reject, object}
  end
end
