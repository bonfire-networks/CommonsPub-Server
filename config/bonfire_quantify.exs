use Mix.Config

config :bonfire_quantify,
  otp_app: :commons_pub,
  web_module: CommonsPub.Web,
  repo_module: CommonsPub.Repo,
  user_schema: CommonsPub.Users.User
  # templates_path: "lib",
