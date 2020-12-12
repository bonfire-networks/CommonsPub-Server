use Mix.Config

config :bonfire_valueflows,
  web_module: CommonsPub.Web,
  repo_module: CommonsPub.Repo,
  user_schema: Pointers.Pointer, # FIXME
  org_schema: Pointers.Pointer # FIXME
  # all_types: []
