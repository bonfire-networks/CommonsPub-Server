# MoodleNet Federated Server 

## About the project

This is the MoodleNet back-end, written in Elixir (running on the Erlang VM, and using the Phoenix web framework). The client API uses GraphQL. The federation API uses [ActivityPub](http://activitypub.rocks/) The MoodleNet front-end is built with React (in a [seperate repo](https://gitlab.com/moodlenet/clients/react)).

This codebase was forked from [CommonsPub](http://commonspub.org/) (project to create a generic federated server, based on the `ActivityPub` and `ActivityStreams` web standards) which was originally forked from [Pleroma](https://git.pleroma.social/pleroma/pleroma). 

---

## Documentation 

Do you wish to try out MoodleNet (backend+frontend)? Read [How-to Deploy MoodleNet](https://gitlab.com/moodlenet/clients/react/blob/develop/README.md#deploying-moodlenet).

Do you wish to deploy the MoodleNet backend in production? Read our [Backend Deployment Docs](https://gitlab.com/moodlenet/servers/federated/blob/develop/DEPLOY.md).

Do you wish to hack on the MoodleNet backend? Read our [Backend Developer FAQs](https://gitlab.com/moodlenet/servers/federated/blob/develop/HACKING.md).

---

## Forks and branches

### Flavours 

CommonsPub comes in different flavours, which are made up of a combination of extensions and probably some custom branding. Each flavour has its own branch in the [CommonsPub repo](https://gitlab.com/CommonsPub/Server) regularly merged back-and-forth with its own repository.

- `flavour/commonspub` - Contains the generic flavour of [CommonsPub](http://commonspub.org) (currently packaged with all extensions except for `extension/valueflows`). 
- `flavour/moodlenet` - The original [MoodleNet](https://gitlab.com/moodlenet/backend) flavour (with only  `extension/activitypub`). 
- `flavour/zenpub` - WIP [ZenPub](https://github.com/dyne/zenpub/) flavour (with all extensions), which will use [ZenRoom](https://zenroom.org/) for public key signing and end-to-end encryption.

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

Please commit your work to the appropriate extension branches (and your WIP to new feature/fix branches as needed). 

Avoid commiting directly to `flavour/commonspub` or any of the flavours. 

#### Merging completed work

If you made changes to an extension used by a flavour, merge it into the appropriate flavour branche(s).

If you made changes to core functionality (`MoodleNet[Web].*` namespaces), merge those (and only those) into `flavour/moodlenet`.

#### Please **avoid mixing flavours!** 

For example, DO NOT merge from `flavour/commonspub`-->`flavour/moodlenet`. 

The only exception to this rule being that we DO merge changes from `flavour/moodlenet`-->`flavour/commonspub` since upstream MoodleNet development is still happening directly in core modules.

#### Merging with upstream 

Regularly merge-request changes from `flavour/moodlenet` to [MoodleNet](https://gitlab.com/moodlenet/backend)'s `develop` branch.

Regularly merge changes from [MoodleNet](https://gitlab.com/moodlenet/backend)'s `develop` branch to `flavour/moodlenet`.


---

## Copyright and License

MoodleNet: Connecting and empowering educators worldwide

Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>

Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>

Licensed under the GNU Affero GPL version 3.0 (GNU AGPLv3).
