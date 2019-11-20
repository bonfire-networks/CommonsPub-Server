# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Instance do
  @moduledoc "A proxy for everything happening on this instance"

  alias MoodleNet.Repo
  alias MoodleNet.Instance.Outbox
  import Ecto.Query
  
  def outbox(opts \\ %{}) do
    Repo.all(outbox_q(opts))
    |> Repo.preload(:activity)
  end
  def outbox_q(_opts) do
    from i in Outbox,
      join: a in assoc(i, :activity),
      where: not is_nil(a.published_at),
      select: i,
      preload: [:activity]
  end
  def count_for_outbox(opts \\ %{}) do
    Repo.one(count_for_outbox_q(opts))
  end
  def count_for_outbox_q(_opts) do
    from i in Outbox,
      join: a in assoc(i, :activity),
      where: not is_nil(a.published_at),
      select: count(i)
  end

end
