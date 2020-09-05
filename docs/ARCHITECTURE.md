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

- `CommonsPub` - Core application logic, schemas etc.
- `CommonsPub.Web` - Phoenix/Absinthe webapp + GraphQL API for `CommonsPub`.
- `ActivityPub` - ActivityPub S2S models, logic and various helper modules (adapted Pleroma code)
- `ActivityPubWeb` - ActivityPub S2S REST endpoints, activity ingestion and push federation facilities (adapted Pleroma code)
- There are new namespaces being added for extensions such as Taxonomy, Geolocation, Measurements, ValueFlows, etc.

### `CommonsPub`

This namespace contains the core business logic. Every `CommonsPub` object type has at least context module (e. g. `CommonsPub.Communities`), a model/schema module (`CommonsPub.Communities.Community`) and a queries module (`CommonsPub.Communities.Queries`).

All `CommonsPub` objects use an ULID as their primary key. We use the pointers library (`CommonsPub.Meta.Pointers`) to reference any object by its primary key without knowing what type it is beforehand. This is very useful as we allow for example following or liking many different types of objects and this approach allows us to store the context of the like/follow by only storing its primary key (see `CommonsPub.Follows.Follow`) for an example.

All context modules have a `one/1` and `many/1` function for fetching objects. These take a keyword list as filters as arguments allowing objects to be fetched by arbitrary criteria defined in the queries modules.

Examples:

```
Communities.one(username: "bob") # Fetching by username
Collections.many(community: "01E9TQP93S8XFSV2ZATX1FQ528") # Fetching collections by its parent community
Resources.many(deleted: nil) # Fetching all undeleted communities
```

Context modules also have functions for creating, updating and deleting objects. These actions are passed to the AP layer via the `CommonsPub.Workers.APPublishWorker` module.

#### Contexts

The `CommonsPub` namespace is occupied mostly by contexts. These are
top level modules which comprise a grouping of:

- A top level library module
- Additional library modules
- OTP services
- Ecto schemas

Here are the current contexts:

- `CommonsPub.Access` (for managing and querying email whitelists)
- `CommonsPub.Activities` (for managing and querying activities, the unit of a feed)
- `CommonsPub.Collections` (for managing and querying collections of resources)
- `CommonsPub.Communities` (for managing and querying communities)
- `CommonsPub.Features` (for managing and querying featured content)
- `CommonsPub.Feeds` (for managing and querying feeds)
- `CommonsPub.Flags` (for managing and querying flags)
- `CommonsPub.Follows` (for managing and querying follows)
- `CommonsPub.Instance` (for managing the local instance)
- `CommonsPub.Mail` (for rendering and sending emails)
- `CommonsPub.Meta` (for managing and querying references to content in many tables)
- `CommonsPub.OAuth` (for OAuth functionality)
- `CommonsPub.Peers` (for managing remote hosts)
- `CommonsPub.Resources` (for managing and querying the resources in collections)
- `CommonsPub.Threads` (for managing and querying threads and comments)
- `CommonsPub.Users` (for managing and querying both local and remote users)
- `CommonsPub.Uploads` (for managing uploaded content)

- `CommonsPub.Characters` (a shared abstraction over users, communities, collections, and other objects that need to have feeds and act as an actor in ActivityPub land)

#### Additional Libraries

- `CommonsPub.Application` (OTP application)
- `CommonsPub.ActivityPub` (ActivityPub integration)
- `CommonsPub.Common` (stuff that gets used everywhere)
- `CommonsPub.GraphQL` (GraphQL abstractions)
- `CommonsPub.MediaProxy` (for fetching remote media)
- `CommonsPub.MetadataScraper` (for scraping metadata from a URL)
- `CommonsPub.Queries` (Helpers for making queries)
- `CommonsPub.Queries` (Helpers for making queries)
- `CommonsPub.ReleaseTasks` (OTP release tasks)
- `CommonsPub.Repo` (Ecto repository)
- `CommonsPub.Workers` (background tasks)
- `CommonsPub.Search` (local search indexing and search API, powered by Meili)

### `CommonsPub.Web`

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

The callback functions defined in `ActivityPub.Adapter` are implemented in `CommonsPub.ActivityPub.Adapter`. Facilities for calling the ActivityPub API are implemented in `CommonsPub.ActivityPub.Publisher`. When implementing federation for a new object type it needs to be implemented both ways: both for outgoing federation in `CommonsPub.ActivityPub.Publisher` and for incoming federation in `CommonsPub.ActivityPub.Adapter`.

## Naming

It is said that naming is one of the four hard problems of computer
science (along with cache management and off-by-one errors). We don't
claim our scheme is the best, but we do strive for consistency.

Naming rules:

- Context names all begin `CommonsPub.` and are named in plural where possible.
- Everything within a context begins with the context name and a `.`
- Ecto schemas should be named in the singular
- Database tables should be named in the singular
- Acronyms in module names should be all uppercase
- OTP services should have the `Service` suffix (without a preceding `.`)
