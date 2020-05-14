# MoodleNet Developer FAQ

*These instructions are for hacking on the MoodleNet backend. If you wish to deploy MoodleNet in production, please refer to our [Deployment Guide](https://gitlab.com/moodlenet/servers/federated/blob/develop/DEPLOY.md)!*

Hello, potential contributor! :-)

This is a work in progress guide to getting MoodleNet up and running as a developer. Please ask questions in the [public Telegram chat](https://t.me/moodlenet_devs) or via GitLab issues if something is not clear.

Happy hacking!


## Getting set up

There are three options. The easy option should work the best for most
users:


### Option 1 (the easy way) - fully managed via docker-compose

1. Dependencies:

* `make`
* Docker
* Docker Compose (recent version)

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

* `4000` - moodlenet http listener
* `5432` - postgres database server


### Option 2 (the middle ground) - docker-managed database

Dependencies:

* A recent elixir version (1.8.0+)

MoodleNet takes some configuration in the form of environment
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

Launch the database (in a second shell, preferably):

```
make dev-db-up
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
   * `DATABASE_HOST`
   * `POSTGRES_USER`
   * `POSTGRES_PASSWORD`
   * `POSTGRES_DB`

2. You will not need to run `make dev-db-up`


## Running

By default, the back-end listens on port 4000 (TCP), so you can access it on http://localhost:4000/ 

The MoodleNet frontend is a seperate app: https://gitlab.com/moodlenet/clients/react

If you haven't set up transactional emails, while in development, you can access emails (such as signup validation) at `/sent_emails`.


## Documentation

The code is somewhat documented inline. You can read the resulting [Module & Function Documentation](https://new.next.moodle.net/docs/server/api-reference.html#modules) on the project website. 

If you add more documentation (thanks!), you can generate HTML docs (using `Exdoc`) by running `mix docs`. 


## Internationalisation

The backend code currently has very few translatable strings, basically error messages transactional emails:

*   Email subject lines in `MoodleNet.Email` (eg: [moodle_net/email.ex#L8](https://gitlab.com/moodlenet/servers/federated/blob/develop/lib/moodle_net/email.ex#L8))
*   Email templates in [moodle_net_web/email/](https://gitlab.com/moodlenet/servers/federated/blob/develop/lib/moodle_net_web/email/templates/)
*   Errors passed through Gettext in `MoodleNetWeb.ErrorHelpers` and `MoodleNetWeb.GraphQL.Errors`

The locale is set using the `MoodleNetWeb.Plugs.SetLocale` plug which checks the header or a param.

If you've added any localisable fields, you should run `mix gettext.extract` to extract them into `/priv/gettext/en/LC_MESSAGES/`. Upload those files to the translation system (eg. Transifex). 

If you've downloaded or received new translated files, copy them to the approriate languages folder(s) in `/priv/gettext/` before rebuilding the app.


## What happens when I get this error?

### (Mix) Package fetch failed

Example:

```
** (Mix) Package fetch failed and no cached copy available (https://repo.hex.pm/tarballs/distillery-2.0.12.tar)
```

In this case, distillery made a new release and retired the old
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

The finished result  should look like this (did you remember to add a
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

## Hacking

MoodleNet is an unusual piece of software, developed in an unusual
way. It started with requests by Moodle users to be able to share and
collaborate on educational resources with their peers.

Hacking on moodlenet is actually pretty fun. The codebase has a unique
feeling to work with and we've relentlessly refactored to manage the
ever-growing complexity that a distributed social network
implies. This said, it is not easy to understand without context,
which is what this section is here to provide.

I have been on the team for nearly a year now, during which time we
have gone from a proof of concept to a (nearly) production-grade
application, despite the entire team being part-time.

### Design Decisions

Feature goals:

* Flexibility for developers and deployments.
* Integrated federation with the existing fediverse.

Operational goals:

* Easy to set up and run.
* Light on resources for small deployments.
* Scalable for large deployments.

Operationally, there's a tension between wanting to be able to scale
moodlenet instances and not wanting to burden small instances with
high resource requirements or difficult setup.

There are no easy answers to this. Our current solution is heavily
reliant on postgresql. We will monitor perforamnce and scaling and
continually evolve our strategy.

### Stack

Our implementation language is [Elixir](https://www.elixir-lang.org/),
a language designed for building reliable systems. We use the
[Phoenix](https://www.phoenixframework.org/) web framework and the
[Absinthe](https://absinthe-graphql.org/) GraphQL Toolkit to deliver a
GraphQL API which the frontend interacts with.

We like our stack and we have no interest in rewriting in PHP, thanks
for not asking.

### Codebase overview

At the top level, there are four seperate namespaces:

* `MoodleNet` - Main application logic, schemas etc.
* `MoodleNetWeb` - Phoenix/Absinthe webapp + GraphQL API for `MoodleNet`.
* `ActivityPub` - ActivityPub federation stack
* `ActivityPubWeb` - Phoenix webapp / ActivityPub API for `ActivityPub`.

MoodleNet and MoodleNetWeb are primarily maintained by @jjl with help from @antoniskalou.

ActivityPub and ActivityPubWeb are primarily maintained by @karenkonou.

### MoodleNet

#### Contexts

The `MoodleNet` namespace is occupied mostly by contexts. These are
top level modules which comprise a grouping of:

* A top level library module
* Additional library modules
* OTP services
* Ecto schemas

Here are the current contexts:

* `MoodleNet.Access` (for managing and querying email whitelists)
* `MoodleNet.Activities` (for managing and querying activities, the unit of a feed)
* `MoodleNet.Actors` (a shared abstraction over users, communities and collections)
* `MoodleNet.Collections` (for managing and querying collections of resources)
* `MoodleNet.Communities` (for managing and querying communities)
* `MoodleNet.Features` (for managing and querying featured content)
* `MoodleNet.Feeds` (for managing and querying feeds)
* `MoodleNet.Flags` (for managing and querying flags)
* `MoodleNet.Follows` (for managing and querying follows)
* `MoodleNet.Instance` (for managing the local instance)
* `MoodleNet.Mail` (for rendering and sending emails)
* `MoodleNet.Meta` (for managing and querying references to content in many tables)
* `MoodleNet.OAuth` (for OAuth functionality)
* `MoodleNet.Peers` (for managing remote hosts)
* `MoodleNet.Resources` (for managing and querying the resources in collections)
* `MoodleNet.Threads` (for managing and querying threads and comments)
* `MoodleNet.Users` (for managing and querying both local and remote users)
* `MoodleNet.Uploads` (for managing uploaded content)

#### Additional Libraries

* `MoodleNet.Application` (OTP application)
* `MoodleNet.ActivityPub` (ActivityPub integration)
* `MoodleNet.Algolia` (Mothership search)
* `MoodleNet.Common` (stuff that gets used everywhere)
* `MoodleNet.GraphQL` (GraphQL abstractions)
* `MoodleNet.MediaProxy` (for fetching remote media)
* `MoodleNet.MetadataScraper` (for scraping metadata from a URL)
* `MoodleNet.Queries` (Helpers for making queries)
* `MoodleNet.Queries` (Helpers for making queries)
* `MoodleNet.ReleaseTasks` (OTP release tasks)
* `MoodleNet.Repo` (Ecto repository)
* `MoodleNet.Workers` (background tasks)

### `MoodleNetWeb`

TODO

* Endpoint
* Router
* Controllers
* Views
* Plugs
* GraphQL
  * Schemas
  * Resolvers
  * Middleware
  * Pipeline
  * Flows

### Naming

It is said that naming is one of the four hard problems of computer
science (along with cache management and off-by-one errors). We don't
claim our scheme is the best, but we do strive for consistency.

Naming rules:

* Context names all begin `MoodleNet.` and are named in plural where possible.
* Everything within a context begins with the context name and a `.`
* Ecto schemas should be named in the singular
* Database tables should be named in the singular
* Acronyms in module names should be all uppercase
* OTP services should have the `Service` suffix (without a preceding `.`)


