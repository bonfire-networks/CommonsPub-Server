# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.MRF.NoOpPolicy do
  @moduledoc "Does nothing (lets the messages go through unmodified)"
  @behaviour ActivityPub.MRF

  @impl true
  def filter(object) do
    {:ok, object}
  end
end
