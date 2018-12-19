# CommonsPub

## About the project

CommonsPub is a generic federated server, based on the ActivityPub and ActivityStreams web standards. 

The back-end is written in Elixir (running on the Erlang VM, and using the Phoenix web framework) to be highly performant and can run on low powered devices like a Raspberry Pi. Each app will likely have a bespoke front-end (though they're of course encouraged to share components).

It was forked from Pleroma with the intention of moving as much functionality as possible into frameworks/libraries, and generally turning it into a generic ActivityPub server that can power many different apps and use cases, all of them as interoperable as possible with each other, and any other ActivityPub-based fediverse app like Mastodon.

The first projects using it are:

* [MoodleNet](https://moodle.com/moodlenet) to empower communities of educators to connect, learn, and curate open content together

* [Open Cooperative Ecosystem](https://opencoopecosystem.net/) to empower economic activities driven by human and ecological needs rather than profit


## Installation

### With Docker (recommended)

The docker image can be found in: https://hub.docker.com/r/moodlenet/moodlenet/

The docker images needs the environment variables to work.
An updated list of them can be found in the file `config/docker.env` in this same repository.

The easiest way to launch the docker image is using the `docker-compose` tool.
The `docker-compose.yml` uses the previous `config/docker.env` to launch a `moodlenet` container
and all the dependencies, currently, only a postgres container is needed it.


#### Docker commands

The first time you launch the docker instance the database is not created.
There are several commands to make the first launch easier.
We will use `docker-compose` to show the commands:

* `docker-compose run --rm web bin/moodle_net create_db` creates the database
* `docker-compose run --rm web bin/moodle_net migrate_db` creates the database and runs the migrations
* `docker-compose run --rm web bin/moodle_net drop_db` drops the database

Other important commands are:

* `docker-compose up` launches the service, by default at the port 4000.
* `docker-compose run --rm web /bin/sh` runs a simple shell inside of the container, useful to explore the image
* `docker-compose run --rm web bin/moodle_net console` runs an `iex` console
* `docker-compose exec web bin/moodle_net remote_console` runs an `iex` console when the service is already running.
* `docker-compose run --rm web bin/moodle_net help` returns all the possible commands

There is a command that currently is not working: `seed_db`.
The reason is that to generate ActivityPub ID we need the URL where the server is running,
but `Phoenix` is not launched in this command.

However, we can still do it.
To seed the database we can run the following command in an `iex` console:

`iex> MoodleNet.ReleaseTasks.seed_db([])`

#### Build Docker image

There is a `Makefile` with two commands:

* `make build` which builds the docker image in `moodlenet:latest` and `moodlenet:$VERSION-$BUILD`
* `make run` which can be used to run the docker built docker image without `docker-compose`

---
### Manual installation

#### 1. Install dependencies

* Postgresql version 9.6 or newer
* Build-essential tools
* Elixir version 1.7.4 with OTP 21 (or newer). If your distribution only has an old version available, check [Elixir's install page](https://elixir-lang.org/install.html) or use a tool like [asdf](https://github.com/asdf-vm/asdf) (run `asdf install` in this directory).

#### 2. Install the app

* Clone this repo.

* Run `mix deps.get` to install elixir dependencies.

* Run `mix generate_config`. This will ask you a few questions about your instance and generate a configuration file in `config/generated_config.exs`. Check that and copy it to either `config/dev.secret.exs` or `config/prod.secret.exs`. It will also create a `config/setup_db.psql`; you may want to double-check this file in case you wanted a different username, or database name than the default. Then you need to run the script as PostgreSQL superuser (i.e. `sudo su postgres -c "psql -f config/setup_db.psql"`). It will create a db user, database and will setup needed extensions that need to be set up. Postgresql super-user privileges are only needed for this step.

* For these next steps, the default will be to run the server using the dev configuration file, `config/dev.secret.exs`. To run them using the prod config file, prefix each command at the shell with `MIX_ENV=prod`. For example: `MIX_ENV=prod mix phx.server`.

* Run `mix ecto.migrate` to run the database migrations. You will have to do this again after certain updates.

* You can check if your instance is configured correctly by running it with `mix phx.server` and checking the instance info endpoint at `/api/v1/instance`. If it shows your uri, name and email correctly, you are configured correctly. If it shows something like `localhost:4000`, your configuration is probably wrong, unless you are running a local development setup.

* The common and convenient way for adding HTTPS is by using Nginx as a reverse proxy. You can look at example Nginx configuration in `installation/moodle_net.nginx`. If you need TLS/SSL certificates for HTTPS, you can look get some for free with letsencrypt: https://letsencrypt.org/
  The simplest way to obtain and install a certificate is to use [Certbot.](https://certbot.eff.org) Depending on your specific setup, certbot may be able to get a certificate and configure your web server automatically.


## Running

By default, CommonsPub listens on port 4000 (TCP), so you can access it on http://localhost:4000/ (if you are on the same machine). In case of an error it will restart automatically.

### Frontends
CommonsPub does not ship with a front-end, as each use case will likely have a customised client app, though compatibility between clients and not reinventing the wheel (such as sharing React.js components) is encouraged. 

### As systemd service (with provided .service file)
[Not tested with system reboot yet!] You'll also want to set up the server to be run as a systemd service. Example .service file can be found in `installation/moodle_net.service` you can put it in `/etc/systemd/system/`.

Running: `service moodle_net start`

Logs can be watched by using `journalctl -fu moodle_net.service`

### Standalone/run by other means
Run `mix phx.server` in repository's root, it will output log into stdout/stderr

### Using an upstream proxy for federation

Add the following to your `dev.secret.exs` or `prod.secret.exs` if you want to proxify all http requests that the server makes to an upstream proxy server:

    config :moodle_net, :http,
      proxy_url: "127.0.0.1:8123"

This is useful for running the server inside Tor or i2p.

## Admin Tasks

If you're running with Docker, all the `mix` commands below should be preceded by `docker exec -it [name_of_commonspub_container]`. You can use your keyboard's tab key to autocomplete thhe container name, which may look something like `commonspub_commonspub_1`.

### Invite a User (when registrations are closed)

Run `mix generate_invite_token` and you will receive an URL which includes an invite code that one person can use to sign up.
 
### Register a User

Run `mix register_user <name> <nickname> <email> <bio> <password>`. The `name` appears on statuses, while the nickname corresponds to the user, e.g. `@nickname@instance.tld`

### Password reset

Run `mix generate_password_reset username` to generate a password reset link that you can then send to the user.

### Moderators

You can make users moderators. They will then be able to delete any post.

Run `mix set_moderator username [true|false]` to make user a moderator or not.

### Monitoring

You can use `iex -S mix run`  to run the app in interactive mode and then enter `:observer.start()` to launch [Erlang's observer](http://erlang.org/doc/apps/observer/observer_ug.html), which among other things will show you an applications tree:
![Observer example](installation/threads_tree.png)

## Troubleshooting

### No incoming federation

Check that you correctly forward the "host" header to backend. It is needed to validate signatures.

---
# Configuring the server

In the `config/` directory, you will find the following relevant files:

* `config.exs`: default base configuration
* `dev.exs`: default additional configuration for `MIX_ENV=dev`
* `prod.exs`: default additional configuration for `MIX_ENV=prod`


Do not modify files in the list above.
Instead, overload the settings by editing the following files:

* `dev.secret.exs`: custom additional configuration for `MIX_ENV=dev`
* `prod.secret.exs`: custom additional configuration for `MIX_ENV=prod`

## Uploads configuration

To configure where to upload files, and wether or not 
you want to remove automatically EXIF data from pictures
being uploaded.

    config :moodle_net, MoodleNet.Upload,
      uploads: "uploads",
      strip_exif: false

* `uploads`: where to put the uploaded files, relative to the app's main directory.
* `strip_exif`: whether or not to remove EXIF data from uploaded pics automatically. 
   This needs Imagemagick installed on the system ( apt install imagemagick ).


## Block functionality

    config :moodle_net, :activitypub,
      accept_blocks: true,
      unfollow_blocked: true,
      outgoing_blocks: true

    config :moodle_net, :user, deny_follow_blocked: true

* `accept_blocks`: whether to accept incoming block activities from
   other instances
* `unfollow_blocked`: whether blocks result in people getting
   unfollowed
* `outgoing_blocks`: whether to federate blocks to other instances
* `deny_follow_blocked`: whether to disallow following an account that
   has blocked the user in question

## Message Rewrite Filters (MRFs)

Modify incoming and outgoing posts.

    config :moodle_net, :instance,
      rewrite_policy: MoodleNet.Web.ActivityPub.MRF.NoOpPolicy

`rewrite_policy` specifies which MRF policies to apply.
It can either be a single policy or a list of policies.
Currently, MRFs availible by default are:

* `MoodleNet.Web.ActivityPub.MRF.NoOpPolicy`
* `MoodleNet.Web.ActivityPub.MRF.DropPolicy`
* `MoodleNet.Web.ActivityPub.MRF.SimplePolicy`
* `MoodleNet.Web.ActivityPub.MRF.RejectNonPublic`

Some policies, such as SimplePolicy and RejectNonPublic,
can be additionally configured in their respective sections.

### NoOpPolicy

Does not modify posts (this is the default `rewrite_policy`)

### DropPolicy

Drops all posts.
It generally does not make sense to use this in production.

### SimplePolicy

Restricts the visibility of posts from certain instances.

    config :moodle_net, :mrf_simple,
      media_removal: [],
      media_nsfw: [],
      federated_timeline_removal: [],
      reject: [],
      accept: []

* `media_removal`: posts from these instances will have attachments 
   removed
* `media_nsfw`: posts from these instances will have attachments marked
   as nsfw
* `federated_timeline_removal`: posts from these instances will be 
   marked as unlisted
* `reject`: posts from these instances will be dropped
* `accept`: if not empty, only posts from these instances will be accepted

### RejectNonPublic

Drops posts with non-public visibility settings.

    config :moodle_net :mrf_rejectnonpublic
      allow_followersonly: false,
      allow_direct: false,

* `allow_followersonly`: whether to allow follower-only posts through
   the filter
* `allow_direct`: whether to allow direct messages through the filter
