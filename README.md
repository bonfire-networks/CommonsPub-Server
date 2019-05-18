# MoodleNet Federated Server 

## About the project

This is the MoodleNet back-end, written in Elixir (running on the Erlang VM, and using the Phoenix web framework). The client API uses GraphQL. The federation API uses [ActivityPub](http://activitypub.rocks/) The MoodleNet front-end is built with React (in a [seperate repo](https://gitlab.com/moodlenet/clients/react?nav_source=navbar)).

This codebase was forked from [CommonsPub](http://commonspub.org/) (project to create a generic federated server, based on the `ActivityPub` and `ActivityStreams` web standards) which was originally forked from [Pleroma](https://git.pleroma.social/pleroma/pleroma). 

---

## Installation

### Configuring the back-end

In the `config/` directory, you will find the following default config files:

* `config.exs`: default base configuration
* `dev.exs`: default extra configuration for `MIX_ENV=dev`
* `prod.exs`: default extra configuration for `MIX_ENV=prod`


Do not modify the files above. Instead, overload the settings by editing the following files:

* `dev.secret.exs`: custom extra configuration for `MIX_ENV=dev`
* `prod.secret.exs`: custom extra configuration for `MIX_ENV=prod`

---

### Install using Docker containers (recommended)
Make sure you have [docker](https://www.docker.com/), a recent [docker-compose](https://docs.docker.com/compose/install/#install-compose) (which supports v3 configs), and [make](https://www.gnu.org/software/make/) installed:
```sh
$ docker version
Docker version 18.09.1-ce
$ docker-compose -v                                                                                                                                              ±[●][develop]
docker-compose version 1.23.2
$ make --version
GNU Make 4.2.1
...
```

Clone this repo and change into the directory:
```sh
$ git clone https://gitlab.com/moodlenet/servers/federated.git
$ cd federated
```

Build the docker image:
```
$ make build
```

If you want to use the docker cache during subsequent build use:
```
$ make build_with_cache
```

Start the docker containers with docker-compose:
```sh
$ docker-compose up
```

App should be running at [http://localhost:4000/](http://localhost:4000/).

If that worked, start the app as a daemon next time:
```sh
$ docker-compose up -d
```

#### Configuration

The docker image can be found in: https://hub.docker.com/r/moodlenet/moodlenet/

The docker image needs the environment variables to work, a list of which can be found in the file `config/docker.env` in this same repository.

The easiest way to launch the docker image is using the `docker-compose` tool.
The `docker-compose.yml` uses `config/docker.env` to launch a `moodlenet` container and all its dependencies, currently that means an extra postgres container.

#### Docker commands

The first time you launch the docker instance the database is not created.
There are several commands to make the first launch easier.
We will use `docker-compose` to show the commands:

* `docker-compose run --rm web bin/moodle_net create_db` creates the database
* `docker-compose run --rm web bin/moodle_net migrate_db` creates the database and runs the migrations
* `docker-compose run --rm web bin/moodle_net drop_db` drops the database

There is a command that currently is not working: `seed_db`.
The reason is that to generate ActivityPub IDs we need the URL where the server is running, but `Phoenix` is not launched in this command.

However, we can do so by running the following command in an `iex` console:

`iex> MoodleNet.ReleaseTasks.seed_db([])`

#### Build Docker image

There is a `Makefile` with two commands:

* `make build` which builds the docker image in `moodlenet:latest` and `moodlenet:$VERSION-$BUILD`
* `make run` which can be used to run the docker built docker image without `docker-compose`

### Devops information

The [Dockerfile](https://gitlab.com/moodlenet/servers/federated/blob/develop/Dockerfile) uses the [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to make the image as small as possible.

It is a very common release using [Distillery](https://hexdocs.pm/distillery/home.html)

It generates the release which is later copied into the final image:
*   [/Dockerfile#L57](https://gitlab.com/moodlenet/servers/federated/blob/develop/Dockerfile#L57)
*   [/Dockerfile#L80](https://gitlab.com/moodlenet/servers/federated/blob/develop/Dockerfile#L80)

---

### Manual installation (without Docker)

#### 1. Install dependencies

* Postgres version 9.6 or newer
* Build tools
* Elixir version 1.7.4 with OTP 21 (or possibly newer). If your distribution only has an old version available, check [Elixir's install page](https://elixir-lang.org/install.html) or use a tool like [asdf](https://github.com/asdf-vm/asdf) (run `asdf install` in this directory).

#### 2. Install the app

* Clone this repo.

* Run `mix deps.get` to install elixir dependencies.

* Run `mix generate_config`. This will ask you a few questions about your instance and generate a configuration file in `config/generated_config.exs`. Check that and copy it to either `config/dev.secret.exs` or `config/prod.secret.exs`. It will also create a `config/setup_db.psql`; you may want to double-check this file in case you wanted a different username, or database name than the default. Then you need to run the script as PostgreSQL superuser (i.e. `sudo su postgres -c "psql -f config/setup_db.psql"`). It will create a db user, database and will setup needed extensions that need to be set up. Postgresql super-user privileges are only needed for this step.

* For these next steps, the default will be to run the server using the dev configuration file, `config/dev.secret.exs`. To run them using the prod config file, prefix each command at the shell with `MIX_ENV=prod`. For example: `MIX_ENV=prod mix phx.server`.

* Run `mix ecto.migrate` to run the database migrations. You will have to do this again after certain updates.

* You can check if your instance is configured correctly by running it with `mix phx.server` and checking the instance info endpoint at `/api/v1/instance`. If it shows your uri, name and email correctly, you are configured correctly. If it shows something like `localhost:4000`, your configuration is probably wrong, unless you are running a local development setup.

This is the MoodleNet back-end, written in Elixir (running on the Erlang VM, and using the Phoenix web framework). The client API uses GraphQL. The federation API uses [ActivityPub](http://activitypub.rocks/). The MoodleNet front-end is built with React (in a [seperate repo](https://gitlab.com/moodlenet/clients/react)).

---

## Doc index

Do you wish to deploy MoodleNet? Read our [Deployment Guide](https://gitlab.com/moodlenet/servers/federated/blob/develop/DEPLOY.md).

Do you wish to develop MoodleNet? Read our [Developer Guide](https://gitlab.com/moodlenet/servers/federated/blob/develop/HACKING.md).

## Copyright and License

MoodleNet: Connecting and empowering educators worldwide

Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>

Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>

Licensed under the GNU Affero GPL version 3.0 (GNU AGPLv3).
