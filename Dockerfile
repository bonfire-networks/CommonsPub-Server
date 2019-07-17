# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.9.0-alpine` image uses
ARG ALPINE_VERSION=3.9

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME
# The version of the application we are building (required)
ARG APP_VSN

FROM elixir:1.9.0-alpine as builder

ENV HOME=/opt/app/ TERM=xterm MIX_ENV=prod

WORKDIR $HOME

# dependencies for comeonin
RUN apk add --no-cache build-base cmake curl git

# Cache elixir deps
COPY mix.exs mix.lock ./
RUN mix do local.hex --force, local.rebar --force, deps.get, deps.compile

COPY . .

RUN mix do phx.digest, distillery.release --env=prod --verbose --no-tar

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

# The name of your application/release (required)
ARG APP_NAME
ARG APP_VSN
ARG APP_BUILD

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev

ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    APP_REVISION=${APP_VSN}-${APP_BUILD}

WORKDIR /opt/app

COPY --from=builder /opt/app/_build/prod/rel/${APP_NAME} /opt/app

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} foreground
