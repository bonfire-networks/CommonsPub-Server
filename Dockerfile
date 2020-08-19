# The version of Elixir to use
# ATTENTION: when changing Elixir version, make sure to update the `ALPINE_VERSION` arg
# as well as the Elixir version in mix.exs and .gitlab-ci.yml and Dockerfile.dev and .tool-versions
ARG ELIXIR_VERSION=1.10.4

# The version of Alpine to use for the final image
# This should match the version of Alpine that the current elixir image (in Step 1) uses
# To find this you need to:
# 1. Locate the dockerfile for the elixir image to get the erlang image version
#    e.g. https://github.com/c0b/docker-elixir/blob/master/1.10/alpine/Dockerfile
# 2. Locate the dockerfile for the corresponding erlang image
#    e.g. https://github.com/erlang/docker-erlang-otp/blob/master/22/alpine/Dockerfile
ARG ALPINE_VERSION=3.11

# The following are build arguments used to change variable parts of the image, they should be set as env variables.
# The name of your application/release (required)
ARG APP_NAME
# The version of the application we are building (required)
ARG APP_VSN

# Step 1 - Build our app
FROM elixir:${ELIXIR_VERSION}-alpine as builder 

ENV HOME=/opt/app/ TERM=xterm MIX_ENV=prod

WORKDIR $HOME

# useful deps
RUN apk add --no-cache curl git rust cargo npm

# dependencies for comeonin
RUN apk add --no-cache make gcc libc-dev

# Cache elixir deps
COPY mix.exs mix.lock ./
RUN mix do local.hex --force, local.rebar --force, deps.get --only prod, deps.compile

COPY assets/package* ./assets/
RUN npm install --prefix assets

COPY . .

RUN npm run deploy --prefix ./assets
RUN mix phx.digest

RUN mix release

# Step 2 - Prepare the server image
# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

# The name of your application/release (required)
ARG APP_NAME
ARG APP_VSN
ARG APP_BUILD
ARG PROXY_FRONTEND_URL

ENV APP_NAME=${APP_NAME} APP_VSN=${APP_VSN} APP_REVISION=${APP_VSN}-${APP_BUILD}

# Essentials
RUN apk add --update --no-cache \
  ca-certificates \
  mailcap \
  openssh-client \
  openssl-dev \
  tzdata \
  bash \
  curl \
  gettext 

WORKDIR /opt/app

# install app 
COPY --from=builder /opt/app/_build/prod/rel/moodle_net /opt/app

# start
CMD ["./_build/prod/rel/moodle_net", "start"]
