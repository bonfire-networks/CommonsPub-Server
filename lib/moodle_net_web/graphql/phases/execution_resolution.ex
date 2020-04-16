# this code is based on Absinthe library: Absinthe.Phase.Document.Execution.Resolution
defmodule MoodleNetWeb.GraphQL.Phase.ExecutionResolution do
  @moduledoc false

  # Runs resolution functions in a blueprint.
  #
  # Blueprint results are placed under `blueprint.result.execution`. This is
  # because the results form basically a new tree from the original blueprint.

  alias Absinthe.{Blueprint, Type, Phase}
  alias Blueprint.{Result, Execution}

  alias Absinthe.Phase
  use Absinthe.Phase

  require Logger

  def run(bp_root, options \\ []) do
      Absinthe.Phase.Document.Execution.Resolution.run(bp_root, options)
  rescue
      error -> debug_exception("The API encountered an exceptional error", error, __STACKTRACE__)
  catch
      error -> debug_exception("The API was thrown an exceptional error", error, __STACKTRACE__)
  end

  defp debug_exception(msg, exception, stacktrace) do
    debug_log(msg, exception, stacktrace)
    if Mix.env == :dev do
      {:error, msg 
        <> ": \n" 
        <> Exception.format_exit(exception) 
        <> "\nStacktrace:" 
        <> Exception.format_stacktrace(stacktrace)
      }
    else
      {:error, msg}
    end
  end

  defp debug_log(msg, exception, stacktrace) do
    Logger.error(msg)
    IO.puts(Exception.format_exit(exception))
    IO.puts(Exception.format_stacktrace(stacktrace))
    Sentry.capture_exception(
      exception,
      stacktrace: stacktrace
    )
  end


  
  # def error(message, path, extra) do
  #   %Phase.Error{
  #     phase: __MODULE__,
  #     message: message,
  #     path: Absinthe.Resolution.path(%{path: path}),
  #     extra: extra
  #   }
  # end

end
