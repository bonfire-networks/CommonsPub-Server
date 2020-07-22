# CommonsPub Architecture

## Hacking

This is an unusual piece of software, developed in an unusual
way. It started with requests by Moodle users to be able to share and
collaborate on educational resources with their peers.

Hacking on it is actually pretty fun. The codebase has a unique
feeling to work with and we've relentlessly refactored to manage the
ever-growing complexity that a distributed social network
implies. This said, it is not easy to understand without context,
which is what this section is here to provide.

## Design Decisions

Feature goals:

- Flexibility for developers and deployments.
- Integrated federation with the existing fediverse.

Operational goals:

- Easy to set up and run.
- Light on resources for small deployments.
- Scalable for large deployments.

Operationally, there's a tension between wanting to be able to scale
instances and not wanting to burden small instances with
high resource requirements or difficult setup.

There are no easy answers to this. Our current solution is heavily
reliant on postgresql. We will monitor perforamnce and scaling and
continually evolve our strategy.

## Stack

Our implementation language is [Elixir](https://www.elixir-lang.org/),
a language designed for building reliable systems. We use the
[Phoenix](https://www.phoenixframework.org/) web framework and the
[Absinthe](https://absinthe-graphql.org/) GraphQL Toolkit to deliver a
GraphQL API which the frontend interacts with.

We like our stack and we have no interest in rewriting in PHP, thanks
for not asking.

## Code Structure

The server code is broadly composed of four parts.

- `MoodleNet` - Core application logic, schemas etc.
- `MoodleNetWeb` - Phoenix/Absinthe webapp + GraphQL API for `MoodleNet`.
- `ActivityPub` - ActivityPub S2S models, logic and various helper modules (adapted Pleroma code)
- `ActivityPubWeb` - ActivityPub S2S REST endpoints, activity ingestion and push federation facilities (adapted Pleroma code)
- There are new namespaces being added for extensions such as Taxonomy, Geolocation, Measurements, ValueFlows, etc.

### `MoodleNet`

This namespace contains the core business logic. Every `MoodleNet` object type has at least context module (e. g. `MoodleNet.Communities`), a model/schema module (`MoodleNet.Communities.Community`) and a queries module (`MoodleNet.Communities.Queries`).

All `MoodleNet` objects use an ULID as their primary key. We use the pointers library (`MoodleNet.Meta.Pointers`) to reference any object by its primary key without knowing what type it is beforehand. This is very useful as we allow for example following or liking many different types of objects and this approach allows us to store the context of the like/follow by only storing its primary key (see `MoodleNet.Follows.Follow`) for an example.

All context modules have a `one/1` and `many/1` function for fetching objects. These take a keyword list as filters as arguments allowing objects to be fetched by arbitrary criteria defined in the queries modules.

Examples:

```
Communities.one(username: "bob") # Fetching by username
Collections.many(community: "01E9TQP93S8XFSV2ZATX1FQ528") # Fetching collections by its parent community
Resources.many(deleted: nil) # Fetching all undeleted communities
```

Context modules also have functions for creating, updating and deleting objects. These actions are passed to the AP layer via the `MoodleNet.Workers.APPublishWorker` module.

#### Contexts

The `MoodleNet` namespace is occupied mostly by contexts. These are
top level modules which comprise a grouping of:

- A top level library module
- Additional library modules
- OTP services
- Ecto schemas

Here are the current contexts:

- `MoodleNet.Access` (for managing and querying email whitelists)
- `MoodleNet.Activities` (for managing and querying activities, the unit of a feed)
- `MoodleNet.Actors` (a shared abstraction over users, communities and collections)
- `MoodleNet.Collections` (for managing and querying collections of resources)
- `MoodleNet.Communities` (for managing and querying communities)
- `MoodleNet.Features` (for managing and querying featured content)
- `MoodleNet.Feeds` (for managing and querying feeds)
- `MoodleNet.Flags` (for managing and querying flags)
- `MoodleNet.Follows` (for managing and querying follows)
- `MoodleNet.Instance` (for managing the local instance)
- `MoodleNet.Mail` (for rendering and sending emails)
- `MoodleNet.Meta` (for managing and querying references to content in many tables)
- `MoodleNet.OAuth` (for OAuth functionality)
- `MoodleNet.Peers` (for managing remote hosts)
- `MoodleNet.Resources` (for managing and querying the resources in collections)
- `MoodleNet.Threads` (for managing and querying threads and comments)
- `MoodleNet.Users` (for managing and querying both local and remote users)
- `MoodleNet.Uploads` (for managing uploaded content)

#### Additional Libraries

- `MoodleNet.Application` (OTP application)
- `MoodleNet.ActivityPub` (ActivityPub integration)
- `MoodleNet.Algolia` (Mothership search)
- `MoodleNet.Common` (stuff that gets used everywhere)
- `MoodleNet.GraphQL` (GraphQL abstractions)
- `MoodleNet.MediaProxy` (for fetching remote media)
- `MoodleNet.MetadataScraper` (for scraping metadata from a URL)
- `MoodleNet.Queries` (Helpers for making queries)
- `MoodleNet.Queries` (Helpers for making queries)
- `MoodleNet.ReleaseTasks` (OTP release tasks)
- `MoodleNet.Repo` (Ecto repository)
- `MoodleNet.Workers` (background tasks)

### `MoodleNetWeb`

Structure:

- Endpoint
- Router
- Controllers
- Views
- Plugs
- GraphQL
  - Schemas
  - Resolvers
  - Middleware
  - Pipeline
  - Flows

See the [GraphQL API documentation](./GRAPHQL.md)

### `ActivityPub`

This namespace handles the ActivityPub logic and stores AP activitities. It is largely adapted Pleroma code with some modifications, for example merging of the activity and object tables and new actor object abstraction.

It also contains some functionality that isn't part of the AP spec but is required for federation:

- `ActivityPub.Keys` - Generating and handling RSA keys for messagage signing
- `ActivityPub.Signature` - Adapter for the HTTPSignature library
- `ActivityPub.WebFinger` - Implementation of the WebFinger protocol
- `ActivityPub.HTTP` - Module for making HTTP requests (wrapper around tesla)
- `ActivityPub.Instances` - Module for storing reachability information about remote instances

`ActivityPub` contains the main API and is documented there. `ActivityPub.Adapter` defines callback functions for the AP library.

### `ActivityPubWeb`

This namespace contains the AP S2S REST API, the activity ingestion pipeline (`ActivityPubWeb.Transmogrifier`) and the push federation facilities (`ActivityPubWeb.Federator`, `ActivityPubWeb.Publisher` and others). The outgoing federation module is designed in a modular way allowing federating through different protocols in the future.

### `ActivityPub` interaction in our application logic

The callback functions defined in `ActivityPub.Adapter` are implemented in `MoodleNet.ActivityPub.Adapter`. Facilities for calling the ActivityPub API are implemented in `MoodleNet.ActivityPub.Publisher`. When implementing federation for a new object type it needs to be implemented both ways: both for outgoing federation in `MoodleNet.ActivityPub.Publisher` and for incoming federation in `MoodleNet.ActivityPub.Adapter`.

## Naming

It is said that naming is one of the four hard problems of computer
science (along with cache management and off-by-one errors). We don't
claim our scheme is the best, but we do strive for consistency.

Naming rules:

- Context names all begin `MoodleNet.` and are named in plural where possible.
- Everything within a context begins with the context name and a `.`
- Ecto schemas should be named in the singular
- Database tables should be named in the singular
- Acronyms in module names should be all uppercase
- OTP services should have the `Service` suffix (without a preceding `.`)
