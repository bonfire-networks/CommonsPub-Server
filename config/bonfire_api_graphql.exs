import Config

config :bonfire_api_graphql,
  otp_app: :commons_pub,
  env: Mix.env(),
  repo_module: CommonsPub.Repo
