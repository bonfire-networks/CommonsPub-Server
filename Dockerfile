
# The version of Alpine to use for the final image
# This should match the version of Alpine that the current elixir image (in Step 2) uses
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
# What web server to use: either "caddy" (with built-in SSL), or "nginx" (roll your own SSL)
ARG WEBSERVER_CHOICE="nginx"


# Step 1 - Maybe build Caddy webserver
FROM abiosoft/caddy:builder as caddy-builder

# What web server to use: either "caddy" (with built-in SSL), or "nginx" (roll your own SSL)
ARG WEBSERVER_CHOICE
ARG version="1.0.5"
ARG plugins="cors,realip,expires,cache,cgi"

RUN echo "Using ${WEBSERVER_CHOICE} web server..."

# build Caddy only if specified in the env var
RUN if [ "$WEBSERVER_CHOICE" = "caddy" ]; then echo "Build Caddy" && go get -v github.com/abiosoft/parent && VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh; else echo "Skip Caddy" && mkdir /install && touch /install/caddy; fi


# Step 2 - Build our app
FROM elixir:1.10.2-alpine as builder 
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


# Step 3 - Prepare the server image
# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

# The name of your application/release (required)
ARG APP_NAME
ARG APP_VSN
ARG APP_BUILD
ARG PROXY_FRONTEND_URL

ENV APP_NAME=${APP_NAME} APP_VSN=${APP_VSN} APP_REVISION=${APP_VSN}-${APP_BUILD}

ENV ACME_AGREE="true"

ENV S6_OVERLAY_VERSION=v1.22.1.0 

# Essentials
RUN apk add --update --no-cache \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    openssl-dev \
    tzdata \
    bash \
    build-base \
    curl \
    gettext 
    # why are git and build-base needed here?

# install s6
RUN curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar xfz - -C / 


# maybe install caddy 
COPY --from=caddy-builder /install/caddy /usr/bin/caddy


# install nginx
RUN apk add --update --no-cache nginx && \
    chown -R nginx:www-data /var/lib/nginx
# redirect logs to st output
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log


# copy s6 and web server config
COPY config/deployment/ /


WORKDIR /opt/app


# install app 
COPY --from=builder /opt/app/_build/prod/rel/moodle_net /opt/app

# prepare to run
RUN chmod +x /utils/shutdown-instance.sh

# start
ENTRYPOINT ["/init"]
CMD []
