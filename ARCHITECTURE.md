# MoodleNet Server Architecture

The backend server is broadly composed of four parts.

* `MoodleNet` - Core business logic
* `MoodleNetWeb` - GraphQL API
* `ActivityPub` - ActivityPub S2S models, logic and various helper modules (adapted Pleroma code)
* `ActivityPubWeb` - ActivityPub S2S REST endpoints, activity ingestion and push federation facilities (adapted Pleroma code)

## MoodleNet

This namespace contains the core business logic. Every MN object type has at least context module (e. g. `MoodleNet.Communities`), a model/schema module (`MoodleNet.Communities.Community`) and a queries module (`MoodleNet.Communities.Queries`).

All MN objects use an ULID as their primary key. We use the pointers library (`MoodleNet.Meta.Pointers`) to reference any object by its primary key without knowing what type it is beforehand. This is very useful as we allow for example following or liking many different types of objects and this approach allows us to store the context of the like/follow by only storing its primary key (see `MoodleNet.Follows.Follow`) for an example.

All context modules have a `one/1` and `many/1` function for fetching objects. These take a keyword list as filters as arguments allowing objects to be fetched by arbitrary criteria defined in the queries modules.

Examples:
```
Communities.one(username: "moodler") # Fetching by username
Collections.many(community: "01E9TQP93S8XFSV2ZATX1FQ528") # Fetching collections by its parent community
Resources.many(deleted: nil) # Fetching all undeleted communities
```

Context modules also have functions for creating, updating and deleting objects. These actions are passed to the AP layer via the `MoodleNet.Workers.APPublishWorker` module.

## MoodleNetWeb

See the [GraphQL API documentation](GRAPHQL.md)

## ActivityPub

This namespace handles the ActivityPub logic and stores AP activitities. It is largely adapted Pleroma code with some modifications, for example merging of the activity and object tables and new actor object abstraction.

It also contains some functionality that isn't part of the AP spec but is required for federation:
* `ActivityPub.Keys` - Generating and handling RSA keys for messagage signing
* `ActivityPub.Signature` - Adapter for the HTTPSignature library
* `ActivityPub.WebFinger` - Implementation of the WebFinger protocol
* `ActivityPub.HTTP` - Module for making HTTP requests (wrapper around tesla)
* `ActivityPub.Instances` - Module for storing reachability information about remote instances

`ActivityPub` contains the main API and is documented there. `ActivityPub.Adapter` defines callback functions for the AP library.

## ActivityPubWeb

This namespace contains the AP S2S REST API, the activity ingestion pipeline (`ActivityPubWeb.Transmogrifier`) and the push federation facilities (`ActivityPubWeb.Federator`, `ActivityPubWeb.Publisher` and others). The outgoing federation module is designed in a modular way allowing federating through different protocols in the future.

## ActivityPub MoodleNet interaction

## The Mothership