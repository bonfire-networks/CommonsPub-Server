import Config

# Choose password hashing backend
# Note that this corresponds with our dependencies in mix.exs
hasher = if config_env() in [:dev, :test], do: Pbkdf2, else: Argon2

config :bonfire_data_identity, Bonfire.Data.Identity.Credential,
  hasher_module: hasher

config :bonfire_common,
  repo_module: CommonsPub.Repo,
  otp_app: :commons_pub

config :bonfire_data_identity, Bonfire.Data.Identity.Account,
  # has_one: [credential:     {Credential,    foreign_key: :id}],
  # has_one: [email:          {Email,         foreign_key: :id}],
  has_one: [instance_admin: {Bonfire.Data.Identity.InstanceAdmin, foreign_key: :id}]
