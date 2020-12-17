use Mix.Config

config :bonfire_valueflows,
  otp_app: :commons_pub,
  web_module: CommonsPub.Web,
  repo_module: CommonsPub.Repo,
  user_schema: Pointers.Pointer, # FIXME
  org_schema: Pointers.Pointer, # FIXME
  valid_agent_schemas: [Bonfire.Data.Identity.User, CommonsPub.Users.User, Pointers.Pointer]
  # all_types: []
