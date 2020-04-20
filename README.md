# MoodleNet Federated Server 

## About the project

This is the MoodleNet back-end, written in Elixir (running on the Erlang VM, and using the Phoenix web framework). The client API uses GraphQL. The federation API uses [ActivityPub](http://activitypub.rocks/) The MoodleNet front-end is built with React (in a [seperate repo](https://gitlab.com/moodlenet/clients/react)).

This codebase was forked from [CommonsPub](http://commonspub.org/) (project to create a generic federated server, based on the `ActivityPub` and `ActivityStreams` web standards) which was originally forked from [Pleroma](https://git.pleroma.social/pleroma/pleroma). 

---

## Documentation index

Do you wish to try out MoodleNet (backend+frontend)? Read [How-to Deploy MoodleNet](https://gitlab.com/moodlenet/clients/react/blob/develop/README.md#deploying-moodlenet).

Do you wish to deploy the MoodleNet backend in production? Read our [Backend Deployment Docs](https://gitlab.com/moodlenet/servers/federated/blob/develop/DEPLOY.md).

Do you wish to hack on the MoodleNet backend? Read our [Backend Developer FAQs](https://gitlab.com/moodlenet/servers/federated/blob/develop/HACKING.md).

## Copyright and License

MoodleNet: Connecting and empowering educators worldwide

Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>

Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>

Licensed under the GNU Affero GPL version 3.0 (GNU AGPLv3).
