# Alex' Thoughts 05/10/18

## Pleroma.Web.ActivityPub

This could be a completely independent library.
Maybe it is a good idea to keep separate ActivityStream (vocabulary and schemas) from ActivityPub (protocol and notifications).
I don't know if schema `Notification` should live in any library.
Specs talk about notifications but it isn't an object or something similar.

### Inbox & Outbox current implementation

I thought it could be like "InboxItem" in FunkWhale implementation: http://docs-funkwhale-funkwhale-549-music-federation-documentation.preview.funkwhale.audio/federation/index.html#activity-creation-and-delivery
`InboxItem` table could be a really good idea.
`Inbox` is a term very clear and specific in the ActivityPub specification,
and furthermore, it would be possible to implement an generic "Inbox" get.

However, it seems we don't implement `Inbox` external `get`s or "Outbox" internal `post`s: https://www.w3.org/TR/activitypub/#Overview

Checking how a message is sent from external server to an actor's `Inbox` I discovered we only support:
  * `Create` Activity types for
    * `Article`, `Note` & `Video` Object type
  * `Follow` Activity type.
  * `Accept` (follows?)
  * `Reject` (follows?)
  * `Like`
  * `Announce`
  * `Update`
    * `Person`, `Application`, `Service`, `Organization`
  * `Delete`
  * `Undo`
    * `Announce`, `Follow`, `Block`, `Like`
  * `Block`

We'll have to implement all of them.
This is going to be really hard to make generic or to add hooks to the possible specific application.

Secondly, reading the actor's `Outbox` it seems we are not sending the actor's activity,
we are sending actor's profile:
  * summary
  * name
  * following list
  * etc

ActivityPub specs says:

>>>
 The outbox is discovered through the outbox property of an actor's profile. The outbox MUST be an OrderedCollection.

The outbox stream contains activities the user has published, subject to the ability of the requestor to retrieve the activity (that is, the contents of the outbox are filtered by the permissions of the person reading it). If a user submits a request without Authorization the server should respond with all of the Public posts. This could potentially be all relevant objects published by the user, though the number of available items is left to the discretion of those implementing and deploying the server.

The outbox accepts HTTP POST requests, with behaviour described in Client to Server Interactions.
>>>

So this has to be fixed.

I still don't know if `Notification` in our code would be similar to `InboxItem`,
but a good idea at least for ActivityPub library.

### Pleroma.Web.ActivityPub.Transmogrifier

The code around the `Inbox` implementation is in this module.
I didn't know what this module does but it has a little bit of doc:

> A module to handle coding from internal to wire ActivityPub and back.

It has difficult to understand function names like `fix_object` which doc says:

> Modifies an incoming AP object (mastodon format) to our internal format.

We have to split this module better.
For a generic library we should have any code related to Mastodon or any other app.
Of course, it is going to be very useful to have a mapper from external to internal data.
We have to find a better name.


# Alex' Thoughts 04/10/18

## Applications and Libraries

What is a Elixir/Erlang application, from elixir docs https://hexdocs.pm/elixir/Application.html:
>>>
Applications are the idiomatic way to package software in Erlang/OTP. To get the idea, they are similar to the “library” concept common in other programming languages, but with some additional characteristics.
An application is a component implementing some specific functionality, with a standardized directory structure, configuration, and lifecycle. Applications are loaded, started, and stopped.
>>>

We currently have only a single application, Pleroma.
I don't think we need more in the short or medium term.

However, we should split `lib/pleroma` directory in at least two directories:

    * `lib/pleroma` where will live the core of our application
    * `lib/pleroma_web` where will live the phoenix stuff

This is the new convention in Phoenix.
It tries to split the application logic and the web interface.
The web is an interface, but any application could have more than one.
We could add a command line interface or GraphQL API.
If we keep the logic in the web, reusing code will be much harder.

In later steps we could add more directories, and therefore, more decoupling.

So `lib/pleroma` will be a real application.
It will define an `Application` module.
However, `lib/pleroma_web` does not define an `Application` module,
it won't load, start and stop.
This will be done by `Pleroma`,
so `PleromaWeb` should not be called `application`.
In absence of a better terminology, we'll name it "library".

So, `PleromaWeb` will receive HTTP request from clients and other servers and 
it will make calls to `Pleroma` application.
This means `Pleroma` should know nothing about HTTP
and `PleromaWeb` should know nothing about Repo or databases.
The main task `PleromaWeb` will be "translate" Pleroma terminology and send it using HTTP protocol.


# Contexts

It is interesting that currently we are not using contexts, at least, as explained in Phoenix.

The current convention of Phoenix would be:

```
lib
├── pleroma_web
│   ├── channels
│   │   └── user_socket.ex
│   ├── controllers
│   │   ├── page_controller.ex
│   │   └── user_controller.ex
│   ├── endpoint.ex
│   ├── gettext.ex
│   ├── router.ex
│   ├── templates
│   │   ├── layout
│   │   │   └── app.html.eex
│   │   ├── page
│   │   │   └── index.html.eex
│   │   └── user
│   │       ├── edit.html.eex
│   │       ├── form.html.eex
│   │       ├── index.html.eex
│   │       ├── new.html.eex
│   │       └── show.html.eex
│   └── views
│       ├── error_helpers.ex
│       ├── error_view.ex
│       ├── layout_view.ex
│       ├── page_view.ex
│       └── user_view.ex
└── pleroma_web.ex
```

I think current convention in Phoenix is bad and it is an inheritance of Ruby on Rails.
I prefer to create contexts,
very similar to what we are doing the now in:

```
lib/pleroma/web
├── mastodon_api
│   ├── mastodon_api_controller.ex
│   ├── mastodon_api.ex
│   ├── mastodon_socket.ex
│   └── views
│       ├── account_view.ex
│       ├── filter_view.ex
│       ├── list_view.ex
│       ├── mastodon_view.ex
│       └── status_view.ex
├── oauth
│   ├── app.ex
│   ├── authorization.ex
│   ├── fallback_controller.ex
│   ├── oauth_controller.ex
│   ├── oauth_view.ex
│   └── token.ex
├── ostatus
│   ├── activity_representer.ex
│   ├── feed_representer.ex
│   ├── handlers
│   │   ├── delete_handler.ex
│   │   ├── follow_handler.ex
│   │   ├── note_handler.ex
│   │   └── unfollow_handler.ex
│   ├── ostatus_controller.ex
│   ├── ostatus.ex
│   └── user_representer.ex
├── router.ex
```

Keeping this in mind, it is very interesting to read the (Phoenix documentation about this)[https://hexdocs.pm/phoenix/contexts.html#content]

The main point is not creating too many applications or libraries just to separates concerns or application logic.
A context has a public API which should be used by other modules or applications, ie:

  * `Pleroma.Actors` is a context main module and it is where the public API.
  * `Pleroma.Actors.create(params)`
  * `Pleroma.Actors.find_by(params)`
  * `Pleroma.Actors.send_notification(actor, notification)`

This context could have internal modules, ie:
  * `Pleroma.Actors.Actor # Schema`
  * `Pleroma.Actors.Finders # Queries`
  * `Pleroma.Actors.CreateCommand # Logic to create an Actor`

Those internal modules should not be used directly by an external contexts and they should not have documentation.
Contexts can talk each other.
In fact different libraries could share context name, ie:
  * When `PleromaWeb.Actors.Controller` receives a new registration request and it will call `Pleroma.Actors.create_actor(params)`

However, sometimes we need to use different context in the same time.
Imagine we add new context: `Pleroma.Statistics`
So anytime a user is created we should call: `Pleroma.Statistics.new_registration(actor)`
If we make this call from `PleromaWeb.Actors.Controller` we can forget to add it in a future interface.
In this case, the appropriate way is to create a new function in the application level:

```
defmodule Pleroma do
  def create_actor(params)
     with {:ok, actor} <- Pleroma.Actors.create(params),
             :ok <- `Pleroma.Statistics.new_registration(actor) do
        {:ok, actor}
     end
  end
end
```

The `Pleroma` application is in charge of making the call between different contexts.

This could turn in a mess very quickly.
Too many big functions in the `Pleroma` module, which is the Public API for the application.

Well, we can just create helper modules like: `Pleroma.CreateActor`.
We can move this function and private helpers functions to this module.
So the only responsibility is to create the actor.
And of course it will be a private module:

```
defmodule Pleroma do
  @doc """wherever"""
  def create_actors(params), do: Pleroma.CreateActor.run(params)
end

defmodule Pleroma.CreateActor do
  @moduledoc false

  def run(params) do
     ...
  end
end
```

This means no documentation at all.
The doc should be in the Contexts (if they are publics) or in `Pleroma` module.

### Contexts for Pleroma

* `Pleroma.Invitations` deals with Invitations
* `Pleroma.ActivityStream` has `Activity`, `Actor`, etc. schemas
* Think about if it makes sense to split `ActivityPub` and `ActivityStream`

