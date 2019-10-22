mix ecto.setup
mix deps.g
mix local.hex --force
mix local.rebar --force
mix local.hex --force -- local.rebar --force
apk add telnet
apk add busybox-extras
telnet
telnet localhost 4000
