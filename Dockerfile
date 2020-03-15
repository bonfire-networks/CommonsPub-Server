# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.9.4-alpine` image uses
# To find this you need to:
# 1. Locate the dockerfile for the elixir image to get the erlang image version
#    e.g. https://github.com/c0b/docker-elixir/blob/master/1.9/alpine/Dockerfile
# 2. Locate the dockerfile for the corresponding erlang image
#    e.g. https://github.com/erlang/docker-erlang-otp/blob/master/22/alpine/Dockerfile
ARG ALPINE_VERSION=3.10

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME
# The version of the application we are building (required)
ARG APP_VSN

FROM elixir:1.9.4-alpine as builder 
# make sure to update the version in .gitlab-ci.yml and Dockerfile.dev as well when switching Elixir version 

ENV HOME=/opt/app/ TERM=xterm MIX_ENV=prod

WORKDIR $HOME

# dependencies for comeonin
RUN apk add --no-cache build-base cmake curl git rust cargo

# Cache elixir deps
COPY mix.exs mix.lock ./
RUN mix do local.hex --force, local.rebar --force, deps.get, deps.compile

COPY . .

RUN mix release

FROM abiosoft/caddy:builder as caddy-builder

ARG version="1.0.3"
ARG plugins="git,cors,realip,expires,cache,cgi"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

# The name of your application/release (required)
ARG APP_NAME
ARG APP_VSN
ARG APP_BUILD

RUN apk add --update --no-cache \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    openssl-dev \
    tzdata \
    bash \
    build-base

ENV APP_NAME=${APP_NAME} APP_VSN=${APP_VSN} APP_REVISION=${APP_VSN}-${APP_BUILD}

ENV ACME_AGREE="true"

WORKDIR /opt/app

# install caddy
COPY --from=caddy-builder /install/caddy /usr/bin/caddy
# validate caddy install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

# install app 
COPY --from=builder /opt/app/_build/prod/rel/${APP_NAME} /opt/app

# prepare to run
COPY config/Caddyfile /opt/app/Caddyfile
COPY config/shutdown-instance.sh /opt/app/shutdown-instance.sh
RUN chmod +x /opt/app/shutdown-instance.sh

ARG PROXY_FRONTEND_URL

# start
CMD trap 'exit' INT; if [ ! -z "$PROXY_FRONTEND_URL" ] ; then echo "Start MoodleNet backend + Caddy proxy..." && caddy --conf /opt/app/Caddyfile ; else echo "Start MoodleNet backend..." && /opt/app/bin/${APP_NAME} start ; fi