# Backend Configuration and Deployment

*These instructions are for setting up the **MoodleNet backend** in production.* 

- *If you wish to deploy the **MoodleNet frontend and backend together**, please refer to our guide to [Deploying MoodleNet](https://gitlab.com/moodlenet/clients/react/blob/develop/README.md#deploying-moodlenet)!*

- *If you wish to run the MoodleNet backend in development, please refer to our [Developer FAQ](https://gitlab.com/moodlenet/servers/federated/blob/develop/HACKING.md)!*


---

## Step 0 - Configure your database

You must provide a postgresql database for moodlenet data storage. We
require postgres 9.4 or above.

If you are running in a restricted environment such as Amazon RDS, you
will need to execute some sql against the database:

```
CREATE EXTENSION IF NOT EXISTS citext;
```

## Step 1 - Configure the backend

MoodleNet needs some environment variables to be configured in order to work (a list of which can be found in the file `config/docker.env` in this same repository).

In the `config/` directory, there are following default config files:

* `config.exs`: default base configuration
* `dev.exs`: default extra configuration for `MIX_ENV=dev`
* `prod.exs`: default extra configuration for `MIX_ENV=prod`

Do NOT modify the files above. Instead, overload any settings from the above files using env variables (a list of which can be found in the file `config/docker.env` in this same repository), or if necessary by editing the following files:

* `dev.secret.exs`: custom extra configuration for `MIX_ENV=dev`
* `prod.secret.exs`: custom extra configuration for `MIX_ENV=prod`


`MAIL_DOMAIN` and `MAIL_KEY` are needed to configure transactional email, sign up at [Mailgun](https://www.mailgun.com/) and then configure the domain name and key.

---

## Step 2 - Install

---

### Option A - Install using Docker containers (recommended)

A pre-built docker image can be found at: https://hub.docker.com/r/moodlenet/moodlenet/

The easiest way to launch the docker image is using the `docker-compose` tool.
The `docker-compose.yml` uses `config/docker.env` to launch a `moodlenet` container along with its dependencies, currently that means an extra postgres container. You may want to add a webserver / reverse proxy yourself.

#### Install with docker-compose

1. Make sure you have [Docker](https://www.docker.com/), a recent [docker-compose](https://docs.docker.com/compose/install/#install-compose) (which supports v3 configs), and [make](https://www.gnu.org/software/make/) installed:

```sh
$ docker version
Docker version 18.09.1-ce

$ docker-compose -v                                                                                                        
docker-compose version 1.23.2

$ make --version
GNU Make 4.2.1
...
```

2. Clone this repository and change into the directory:

```sh
$ git clone https://gitlab.com/moodlenet/servers/federated.git moodlenet-backend
$ cd moodlenet-backend
```

3. Build the docker image.

**Skip this step if you want to use the pre-built image provided by MoodleNet on Docker cloud instead.**

```

$ make build

$ make tag_latest
```

4. Start the docker containers with docker-compose:

```sh
$ docker-compose up
```

5. The backend should now be running at [http://localhost:4000/](http://localhost:4000/).

6. If that worked, start the app as a daemon next time:

```sh
$ docker-compose up -d
```

#### Docker commands

* `docker-compose up` launches the service, by default at the port 4000.
* `docker-compose run --rm backend bin/moodle_net` returns all the possible commands
* `docker-compose run --rm backend /bin/sh` runs a simple shell inside of the container, useful to explore the image
* `docker-compose run --rm backend bin/moodle_net start_iex` starts a new `iex` console
* `docker-compose run backend bin/moodle_net remote` runs an `iex` console when the service is already running.

There are some useful release tasks under `MoodleNet.ReleaseTasks.` that can be run in an `iex` console:

- `create_db` starts the app, creates the DB, and stops 
- `create_repos` creates the DB on already running app
- `drop_db` starts the app, deletes the DB, and stops  
- `drop_repos` deletes the DB 
- `empty_db` starts the app, runs all down migrations, and stops  
- `empty_repos` runs all down migrations
- `migrate_db` starts the app, runs all up migrations, and stops 
- `migrate_repos` runs all up migrations
- `rollback_db` rolls back the previous migration

For example: 
`iex> MoodleNet.ReleaseTasks.create_db` to create your database if it doesn't already exist.


#### Building a Docker image

The [Dockerfile](https://gitlab.com/moodlenet/servers/federated/blob/develop/Dockerfile) uses the [multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to make the image as small as possible. It is a very common release using OTP releases. It generates the release which is later copied into the final image.

There is a `Makefile` with two commands:

* `make build` which builds the docker image in `moodlenet:latest` and `moodlenet:$VERSION-$BUILD`
* `make run` which can be used to run the docker built docker image without `docker-compose`

---

### Option B - Manual installation without Docker

#### Dependencies

* Postgres version 9.6 or newer
* Build tools
* Elixir version 1.9.0 with OTP 22 (or possibly newer). If your distribution only has an old version available, check [Elixir's install page](https://elixir-lang.org/install.html) or use a tool like [asdf](https://github.com/asdf-vm/asdf) (run `asdf install` in this directory).

#### Quickstart

The quick way to get started with building a release, assuming that elixir and erlang are already installed.

```bash
$ export MIX_ENV=prod
$ mix deps.get
$ mix release
# TODO: load required env variables
$ _build/prod/rel/moodle_net/bin/moodle_net eval 'MoodleNet.ReleaseTasks.create_db()'
# DB created
$ _build/prod/rel/moodle_net/bin/moodle_net eval 'MoodleNet.ReleaseTasks.migrate_db()'
# DB migrated
$ _build/prod/rel/moodle_net/bin/moodle_net start
# App started in foreground
```

See the section on [Runtime Configuration](#runtime-configuration) for information on exporting environment variables.

#### B-1. Building the release

* Clone this repo.
* Make sure you have erlang and elixir installed (check `Dockerfile` for what version we're currently using)
* Run `mix deps.get` to install elixir dependencies.
* From here on out, you may want to consider what your `MIX_ENV` is set to. For production, ensure that you either export `MIX_ENV=prod` or use it for each command. Continuing, we are assuming `MIX_ENV=prod`.
* Run `mix release` to create an elixir release. This will create an executable in your `_build/prod/rel/moodle_net` directory. We will be using the `bin/moodle_net` executable from here on.

#### B-2. Running the release

* Export all required environment variables. See [Runtime Configuration](#runtime-configuration) section.

* Create a database, if one is not created already with `bin/moodle_net eval 'MoodleNet.ReleaseTasks.create_db()'`.
* You will likely also want to run the migrations. This is done similarly with `bin/moodle_net eval 'MoodleNet.ReleaseTasks.migrate_db()'`.
* If you’re using RDS or some other locked down DB, you may need to run     `CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;` on your database with elevated privileges.


* You can check if your instance is configured correctly by running it with `moodle_net start` 

* To run the instance as a daemon, use `bin/moodle_net daemon`.

#### B-3. Adding HTTPS

The common and convenient way for adding HTTPS is by using Nginx or Caddyserver as a reverse proxy. 

Caddyserver handles generating and setting up HTTPS certificates automatically, but if you need TLS/SSL certificates for nginx, you can look get some for free with [letsencrypt](https://letsencrypt.org/). The simplest way to obtain and install a certificate is to use [Certbot.](https://certbot.eff.org). Depending on your specific setup, certbot may be able to get a certificate and configure your web server automatically.
  
#### Runtime configuration

You will need to load the required environment variables for the release to run properly. 

See [`config/releases.exs`](config/releases.exs) for all used variables. Consider also viewing there [`config/docker.env`](config/docker.env) file for some examples of values.

---

## Step 3 - Run

By default, the backend listens on port 4000 (TCP), so you can access it on http://localhost:4000/ (if you are on the same machine). In case of an error it will restart automatically.

The MoodleNet frontend is a seperate app: https://gitlab.com/moodlenet/clients/react
