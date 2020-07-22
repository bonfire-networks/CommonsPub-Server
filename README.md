# CommonsPub Federated Server

## About the project

[CommonsPub](http://commonspub.org) is a project to create a generic federated server, based on the `ActivityPub` and `ActivityStreams` web standards).

This is the back-end, written in Elixir (running on the Erlang VM, and using the Phoenix web framework).
The federation API uses [ActivityPub](http://activitypub.rocks/)
The client API uses GraphQL.
The front-end is built with React (in a [seperate repo](https://gitlab.com/CommonsPub/Client).

This codebase was forked from [MoodleNet](http://moodle.net/), which was originally forked from [Pleroma](https://git.pleroma.social/pleroma/pleroma).

---

## Documentation

- [Deploying an instance](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/DEPLOY.md)

- [Development setup](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/HACKING.md)

- [Architecture overview](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/ARCHITECTURE.md)

- [GraphQL API quickstart](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/GRAPHQL.md)

- [Federation message rewrite facility](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/MRF.md)

- Run `mix docs` (or `make dev-docs` if using docker) to generate documentation from the codebase comments, which will appear in `docs/exdoc`

---

## Forks and branches

### Flavours

CommonsPub comes in different flavours, which are made up of a combination of extensions and probably some custom branding. Each flavour has its own branch in the [CommonsPub repo](https://gitlab.com/CommonsPub/Server) regularly merged back-and-forth with its own repository.

- `flavour/commonspub` - Contains the generic flavour of [CommonsPub](http://commonspub.org) (currently packaged with all extensions except for `extension/valueflows`).
- `flavour/moodlenet` - The original [MoodleNet](https://gitlab.com/moodlenet/backend) flavour (with only `extension/activitypub`).
- `flavour/zenpub` - WIP [ZenPub](https://github.com/dyne/zenpub/) flavour (with all extensions), which will use [ZenRoom](https://zenroom.org/) for public key signing and end-to-end encryption.

### Extensions

New functionality is being developed in seperate namespaces in order to make the software more modular (there are future plans for a plugin system). Each "extension" has its own branch in the [CommonsPub repo](https://gitlab.com/CommonsPub/Server):

- `extension/activitypub` - Implementation of the [ActivityPub](http://activitypub.rocks/) federation protocol.
- `extension/valueflows` - WIP implementation of the [ValueFlows](https://valueflo.ws/) economic vocabulary, to power distributed economic networks for the next economy.
- `extension/circle` - Adds functionality for circles to maintain a shared profile.
- `extension/taxonomy` - WIP to enable user-maintained taxonomies and tagging objects with tree-based categories.
- `extension/measurement` - Various units and measures for indicating amounts (incl duration).
- `extension/locales` - Extensive schema of languages/countries/etc. The data is also open and shall be made available oustide the repo.
- `extension/geolocation` - Shared 'spatial things' database for tagging objects with a location.

### Commit & merge workflow

Please commit your work to the appropriate extension branches (and your WIP to new feature/fix branches as needed).

Avoid commiting directly to `flavour/commonspub` or any of the flavours.

#### Merging completed work

If you made changes to an extension used by a flavour, merge it into the appropriate flavour branche(s).

#### Please **avoid mixing flavours!**

For example, DO NOT merge directly between `flavour/commonspub`<-->`flavour/zenpub` unless you use the `./cpub-merge-from-branch.sh` script.

---

## Copyright and License

Copyright © 2018-2019 by Git Contributors.

Contains code from [MoodleNet](http://moodle.net/), Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>

Licensed under the GNU Affero GPL version 3.0 (GNU AGPLv3).
