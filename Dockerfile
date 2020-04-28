
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
# What web server to use
ARG WEBSERVER_CHOICE="nginx"

# Step 1 - Build our app
FROM elixir:1.10.2-alpine as builder 
# when changing Elixir version, make sure to update the `ALPINE_VERSION` 
# as well as the Elixir version in .gitlab-ci.yml and Dockerfile.dev 

ENV HOME=/opt/app/ TERM=xterm MIX_ENV=prod

WORKDIR $HOME

# dependencies for comeonin
RUN apk add --no-cache build-base cmake curl git rust cargo

# Cache elixir deps
COPY mix.exs mix.lock ./
RUN mix do local.hex --force, local.rebar --force, deps.get, deps.compile

COPY . .

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
RUN set -eux; \
  ARCH="$(apk --print-arch)"; echo ${ARCH}; \
  case "${ARCH}" in \
  amd64|x86_64) \
  curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar xfz - -C / \
  ;; \
  i386) \
  curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-x86.tar.gz | tar xfz - -C / \
  ;; \
  armv7) \
  curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-arm.tar.gz | tar xfz - -C / \
  ;; \
  *) \
  curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.gz | tar xfz - -C / \
  ;; \
  esac; 

# install nginx
RUN apk add --update --no-cache nginx nginx-mod-http-lua && \
  chown -R nginx:www-data /var/lib/nginx && \
  chown -R root:nginx /var/run/s6/services/ && chmod g+w -R /var/run/s6/services/ 
# ^ to enable shutdown-instance script

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
