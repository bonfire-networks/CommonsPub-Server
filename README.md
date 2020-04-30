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

Do you wish to try it out (backend+frontend)? Read [How-to Deploy](https://gitlab.com/CommonsPub/Client/-/blob/develop/README.md#deploying).

Do you wish to deploy the backend in production? Read our [Backend Deployment Docs](https://gitlab.com/CommonsPub/Server/blob/develop/DEPLOY.md).

Do you wish to hack on the backend? Read our [Backend Developer FAQs](https://gitlab.com/CommonsPub/Server/blob/develop/HACKING.md).

---

## Forks and branches

### Flavours 

CommonsPub comes in different flavours, which are made up of a combination of extensions and probably some custom branding. Each flavour has its own branch in the [CommonsPub repo](https://gitlab.com/CommonsPub/Server) regularly merged back-and-forth with its own repository.

- `flavour/commonspub` - Contains the generic flavour of **CommonsPub** (currently packaged with all extensions except for `extension/valueflows`). 
- `flavour/moodlenet` - The original [MoodleNet](https://gitlab.com/moodlenet/backend) flavour (with no extensions). 
- `flavour/zenpub` - WIP [ZenPub](https://github.com/dyne/zenpub/) flavour, which will use [ZenRoom](https://zenroom.org/) for public key signing and end-to-end encryption.

### Extensions

New functionality is being developed in seperate namespaces in order to make the software more modular (there are future plans for a plugin system). Each "extension" has its own branch in the [CommonsPub repo](https://gitlab.com/CommonsPub/Server):

- `extension/activitypub` - Implementation of the [ActivityPub](http://activitypub.rocks/) federation protocol.
- `extension/valueflows` - WIP implementation of the [ValueFlows](https://valueflo.ws/) economic vocabulary, to power distributed economic networks for the next economy.
- `extension/organisation` - Adds functionality for organisations to maintain a shared profile.
- `extension/taxonomy` - WIP to enable user-maintained taxonomies and tagging objects with tree-based categories. 
- `extension/measurement` - Various units and measures for indicating amounts (incl duration).
- `extension/locales` - Extensive schema of languages/countries/etc. The data is also open and shall be made available oustide the repo.
- `extension/geolocation` - Shared 'spatial things' database for tagging objects with a location.

### Commit & merge workflow

Please commit your WIP to extension branches (or new feature/fix branches as needed). Avoid commiting directly to `flavour/commonspub` or any of the flavours. Once done, merge your branch into `flavour/commonspub`.

If you make changes to core functionality, merge those (and only those) into `flavour/moodlenet`.

Please **avoid mixing flavours!** 
For example, DO NOT merge from `flavour/commonspub`-->`flavour/moodlenet`. (The only exception to this rule being that we DO merge changes from `flavour/moodlenet`-->`flavour/commonspub` since upstream MoodleNet development is still happening directly in core modules.)

Regularly merge-request changes from `flavour/moodlenet` to [MoodleNet](https://gitlab.com/moodlenet/backend)'s `develop` branch.

Regularly merge changes from [MoodleNet](https://gitlab.com/moodlenet/backend)'s `develop` branch to `flavour/moodlenet`.


---

## Copyright and License

Copyright © 2018-2019 by Git Contributors.

Contains code from [MoodleNet](http://moodle.net/), Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>

Licensed under the GNU Affero GPL version 3.0 (GNU AGPLv3).
