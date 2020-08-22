# ZenPub Federated Server

## About the project

ZenPub is a WIP backend for the Reflow project, which has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No 820937.

It is a flavour of [CommonsPub](http://commonspub.org), a federated app ecosystem based on the `ActivityPub` and `ActivityStreams` web standards).

This is the main repository, written in Elixir (running on Erlang/OTP).

The federation API uses [ActivityPub](http://activitypub.rocks/) and the client API uses [GraphQL](https://graphql.org/).


---

## Documentation

Do you want to...

- Read about the CommonsPub architecture? Read our [overview](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/ARCHITECTURE.md).

- Hack on the code? Read our [Developer FAQs](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/HACKING.md).

- Understand the client API? Read our [GraphQL guide](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/GRAPHQL.md).

- Deploy in production? Read our [Deployment Docs](https://gitlab.com/CommonsPub/Server/blob/flavour/commonspub/docs/DEPLOY.md).

---

## Forks and branches

### Flavours

CommonsPub comes in different flavours, which are made up of a combination of extensions and probably some custom config and branding. Each flavour has its own branch in the [CommonsPub repo](https://gitlab.com/CommonsPub/Server):

- `flavour/commonspub` - Contains the generic flavour of [CommonsPub](http://commonspub.org) (currently packaged with all extensions)
- `flavour/zenpub` - WIP [ZenPub](https://github.com/dyne/zenpub/) flavour (which will use [ZenRoom](https://zenroom.org/) for public key signing and end-to-end encryption
- `flavour/haha` - WIP for [HAHA Academy](https://haha.academy/)

### Extensions

Features are being developed in seperate namespaces in order to make the software more modular (to then be spun out into individual libraries):

- `lib/activity_pub` and `lib/activity_pub_web` - Implementation of the [ActivityPub](http://activitypub.rocks/) federation protocol.
- `lib/extensions/value_flows` - WIP implementation of the [ValueFlows](https://valueflo.ws/) economic vocabulary, to power distributed economic networks for the next economy.
- `lib/extensions/organisations` - Adds functionality for organisations to maintain a shared profile.
- `lib/extensions/tags` - For tagging, @ mentions, and user-maintained taxonomies of categories.
- `lib/extensions/measurements` - Various units and measures for indicating amounts (incl duration).
- `lib/extensions/locales` - Extensive schema of languages/countries/etc. The data is also open and shall be made available oustide the repo.
- `lib/extensions/geolocations` - Shared 'spatial things' database for tagging objects with a location.

#### Please **avoid mixing flavours!**

For example, do not merge directly from `flavour/commonspub`-->`flavour/zenpub`.

---

## Licensing

CommonsPub is licensed under the GNU Affero GPL version 3.0 (GNU AGPLv3).

Copyright © 2017-2020 by all contributors.

This repository includes code from:

- [CommonsPub](https://commonspub.org), copyright (c) 2018-2020, CommonsPub Contributors
- [Reflow](https://reflowproject.eu), copyright (c) 2020 Dyne.org foundation, Amsterdam
- [HAHA Academy](https://haha.academy/), copyright (c) 2020, Mittetulundusühing HAHA Academy
- [MoodleNet](http://moodle.net), copyright (c) 2018-2020 Moodle Pty Ltd
- [Pleroma](https://pleroma.social), copyright (c) 2017-2020, Pleroma Authors

For a list of linked libraries, including their origin and licenses, see [docs/DEPENDENCIES.md](./docs/DEPENDENCIES.md)
