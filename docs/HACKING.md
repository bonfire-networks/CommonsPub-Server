# Development setup

_These instructions are for hacking on the backend. If you wish to deploy in production, please refer to our [Deployment Guide](./DEPLOY.md)!_

Hello, potential contributor! :-)

This is a work in progress guide to getting up and running as a developer. Please ask questions in the issue tracker if something is not clear.

Happy hacking!

## Getting set up

There are three options. The easy option should work the best for most
users:

### Option 1 (the easy way) - fully managed via docker-compose

1. Dependencies:

- `make`
- Docker
- Docker Compose (recent version)

2. From a fresh checkout, download the dependencies and setup the database:

```
make dev-setup
```

3. You should then be able to run with:

```
make dev
```

#### Other useful makefile tasks

- `make dev-build` - rebuild the dev docker image
- `make dev-rebuild` - `dev-build`, but without caches
- `make dev-db` - rebuild the development database
- `make dev-test-db` - rebuild the test database
- `make dev-test` - run the tests
- `make dev-db-up` - launch only the database

#### Forwarded ports

- `4000` - http listener
- `5432` - postgres database server

### Option 2 (the middle ground) - docker-managed database & search index

Dependencies:

- A recent elixir version (1.8.0+)

The app takes some configuration in the form of environment
variables so we don't need to rebuild the docker images to change the
configuration. The first task therefore is to export the development
environment in the current shell:

```
eval "$(make dev-exports)"
```

You can then install the elixir deps:

```
mix deps.get
```

Launch the database & search index (in a second shell, preferably):

```
make dev-services-up
```

And reset it:

```
mix ecto.reset
```

Finally, you may launch the application in iex:

```
iex -S mix phx.server
```

### Option 3 (the hard metal one) - fully manual

If you wish to avoid docker entirely, you will need to follow the
same steps as option 2, except:

1. After setting the environment with `eval $(make dev-exports)`, you
   will need to export the following variables in the environment to
   match the configuration of your database:

   - `DATABASE_HOST`
   - `POSTGRES_USER`
   - `POSTGRES_PASSWORD`
   - `POSTGRES_DB`

2. You will not need to run `make dev-db-up`

## Running

By default, the back-end listens on port 4000 (TCP), so you can access it on http://localhost:4000/

The frontend is (in a [seperate repo](https://gitlab.com/CommonsPub/Client).

If you haven't set up transactional emails, while in development, you can access emails (such as signup validation) at `/sent_emails`.

## Documentation

The code is somewhat documented inline. You can generate HTML docs (using `Exdoc`) by running `mix docs`.

## Internationalisation

The backend code currently has very few translatable strings, basically error messages transactional emails:

- Email subject lines in `MoodleNet.Email` (eg: [moodle_net/email.ex#L8](https://gitlab.com/moodlenet/servers/federated/blob/develop/lib/moodle_net/email.ex#L8))
- Email templates in [moodle_net_web/email/](https://gitlab.com/moodlenet/servers/federated/blob/develop/lib/moodle_net_web/email/templates/)
- Errors passed through Gettext in `MoodleNetWeb.ErrorHelpers` and `MoodleNetWeb.GraphQL.Errors`

The locale is set using the `MoodleNetWeb.Plugs.SetLocale` plug which checks the header or a param.

If you've added any localisable fields, you should run `mix gettext.extract` to extract them into `/priv/gettext/en/LC_MESSAGES/`. Upload those files to the translation system (eg. Transifex).

If you've downloaded or received new translated files, copy them to the approriate languages folder(s) in `/priv/gettext/` before rebuilding the app.

## What happens when I get this error?

### (Mix) Package fetch failed

Example:

```
** (Mix) Package fetch failed and no cached copy available (https://repo.hex.pm/tarballs/distillery-2.0.12.tar)
```

In this case, distillery (as an example of a dependency) made a new release and retired the old
release from hex. The new version (`2.0.14`) is quite close to the
version we were depending on (`2.0.12`), so we chose to upgrade:

```shell
mix deps.update distillery
```

This respects the version bounds in `mix.exs` (`~> 2.0`).

### `(DBConnection.ConnectionError) tcp recv: closed`

Example:

```
** (DBConnection.ConnectionError) tcp recv: closed (the connection was closed by the pool, possibly due to a timeout or because the pool has been terminated)
```

In this case, the seeds were unable to complete because a query took
too long to execute on your machine. You can configure the timeout to
be larger in the `dev` environment:

1. Open `config/dev.exs` in your editor.
2. Find the database configuration (search for `MoodleNet.Repo`).
3. Add `timeout: 60_000` to the list of options.

The finished result should look like this (did you remember to add a
comma at the end of the `pool_size` line?):

```
config :moodle_net, MoodleNet.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "moodle_net_dev",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool_size: 10,
  timeout: 60_000
```
