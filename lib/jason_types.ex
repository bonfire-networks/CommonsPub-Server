Postgrex.Types.define(
  MoodleNet.PostgresTypes,
  [] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)
