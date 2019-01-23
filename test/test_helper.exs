ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(MoodleNet.Repo, :manual)

ExUnit.configure(exclude: :external)
