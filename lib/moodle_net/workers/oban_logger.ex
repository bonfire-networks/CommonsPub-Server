defmodule MoodleNet.Workers.ObanLogger do
  require Logger

  def handle_event([:oban, :failure], _timing, meta, nil) do
    Logger.error("[#{meta.queue}] #{meta.worker} job ID #{meta.id} failed: #{inspect(meta.kind)}. args: #{inspect(meta.args)} error: #{inspect(meta.error)}")
    for line <- meta.stack do
      Logger.error("[#{meta.queue}: #{meta.id}] #{inspect(line)}")
    end

    Sentry.Event.create_event(
      message: """
      #{meta.worker} Job failed.
      #{inspect(meta.error)}
      """,
      stacktrace: meta.stack,
      event_source: meta.worker,
      extra: %{job: meta.id, args: meta.args, kind: meta.kind},
      level: :error
    )
    |> Sentry.send_event()
  end
end
