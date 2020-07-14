# MoodleNet Server Architecture

The backend server is broadly composed of four parts.

* `MoodleNet` - Core business logic
* `MoodleNetWeb` - GraphQL API
* `ActivityPub` - ActivityPub S2S models, logic and various helper modules (adapted Pleroma code)
* `ActivityPubWeb` - ActivityPub S2S REST endpoints, activity ingestion and push federation facilities (adapted Pleroma code)

## MoodleNet

This namespace contains the core business logic. Every MN object type has at least context module (e. g. `MoodleNet.Communities`), a model/schema module (`MoodleNet.Communities.Community`) and a queries module (`MoodleNet.Communities.Queries`).

All MN objects use an ULID as their primary key. We use the pointers library (`MoodleNet.Meta.Pointers`) to reference any object by its primary key without knowing what type it is beforehand. This is very useful as we allow for example following or liking many different types of objects and this approach allows us to store the context of the like/follow by only storing its primary key (see `MoodleNet.Follows.Follow`) for an example.

## MoodleNetWeb

See the [GraphQL API documentation](GRAPHQL.md)