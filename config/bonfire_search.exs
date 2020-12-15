use Mix.Config

config :bonfire_search,
  disable_indexing: System.get_env("SEARCH_INDEXING_DISABLED", "false"),
  env: Mix.env(),
  web_module: Bonfire.Web,
  adapter: Bonfire.Search.Meili,
  instance: System.get_env("SEARCH_MEILI_INSTANCE", "http://search:7700"), # protocol, hostname and port
  api_key: System.get_env("MEILI_MASTER_KEY", "make-sure-to-change-me") # secret key
