# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Workers.GargageCollector do
  use Oban.Worker, queue: "mn_garbage_collector",
    max_attempts: 1, # If it fails, it fails
    unique: [period: 600] # For emergencies only, once a week is better

  import Ecto.Query

  @impl Worker
  def perform(override_opts, _job) do
    opts = Map.new(Application.fetch_env!(:moodle_net, __MODULE__))
    opts = Enum.reduce(override_opts, opts, &option/2)
    stats = %{mark: mark(opts), sweep: sweep(opts)}
    :ok
  end

  defp mark(%{mark: mark}), do: Enum.reduce(mark, %{}, &mark/2)

  defp mark(context, stats) do
    Map.put(stats, context, timed(fn -> context.mark() end))
  end

  defp sweep(%{sweep: sweep}=options), do: Enum.reduce(sweep, %{}, &sweep(options, &1, &2))

  defp sweep(%{grace: grace}, context, stats) do
    Map.put(stats, context, timed(fn -> context.sweep(grace) end))
  end

  defp phase(fun) do
    then = System.monotonic_time(:millisecond)
    count = fun.()
    now = System.monotonic_time(:millisecond)
    %{time: now - then, count: count}
  end

  defp option({"mark", v}, opts) when is_list(v), do: Map.put(opts, :mark, Enum.map(v, &module/1))
  defp option({"sweep", v}, opts) when is_list(v), do: Map.put(opts, :sweep, Enum.map(v, &module/1)
  defp option({"grace", v}, opts) when is_integer(v), do: Map.put(opts, :grace, v)

  defp module(str), do: String.to_existing_atom(str)

end
