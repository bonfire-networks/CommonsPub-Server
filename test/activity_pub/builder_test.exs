defmodule ActivityPub.BuilderTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Builder

  alias ActivityPub.{Entity, BuildError}
  import ActivityPub.Guards

  @context ["https://www.w3.org/ns/activitystreams", %{"@language" => "es"}]

  describe "new" do
    test "builds new empty objects" do
      assert {:ok, entity} = Builder.new()
      assert is_entity(entity)
      assert has_aspect(entity, ActivityPub.ObjectAspect)
      assert Entity.status(entity) == :new
      assert Entity.local?(entity) == true

      assert entity[:"@context"] == ActivityPub.Context.default()
      assert entity.content == %{}
      assert entity.name == %{}
      assert entity.summary == %{}

      assert %{
               id: nil,
               duration: nil,
               media_type: nil,
               end_time: nil,
               published: nil,
               start_time: nil,
               updated: nil,
               bcc: [],
               bto: [],
               cc: [],
               to: [],
               attachment: [],
               attributed_to: [],
               audience: [],
               context: [],
               generator: [],
               icon: [],
               image: [],
               in_reply_to: nil,
               location: [],
               replies: nil,
               tag: []
             } = entity
    end

    test "works with translatable fields" do
      params = %{
        "@context" => @context,
        "content" => "string"
      }

      assert {:ok, entity} = Builder.new(params)
      assert %{content: %{"es" => "string"}} = entity

      content = %{"en" => "string", "fr" => "string"}

      params = %{
        "@context" => @context,
        "content" => content
      }

      assert {:ok, entity} = Builder.new(params)
      assert %{content: ^content} = entity
    end

    test "supports extra fields" do
      assert {:ok, entity} = Builder.new(extra_field: "extra")
      assert %{"extra_field" => "extra"} = entity
    end

    test "builds assocs" do
      params = %{
        "@context": @context,
        name: "test",
        context: %{
          content: "A context"
        }
      }

      assert {:ok, entity} = Builder.new(params)

      assert %{
               name: %{"es" => "test"},
               context: [
                 %{
                   content: %{"es" => "A context"}
                 }
               ]
             } = entity

      assert entity[:"@context"] == hd(entity.context)[:"@context"]
    end

    test "returns error" do
      assert {:error, error} = Builder.new(updated: "not_a_date")
      assert %BuildError{path: ["updated"], message: "is invalid", value: "not_a_date"} = error
    end

    test "returns inner error" do
      map = %{context: %{updated: "not_a_date"}}
      assert {:error, error} = Builder.new(map)

      assert %BuildError{
               path: ["context.0", "updated"],
               message: "is invalid",
               value: "not_a_date"
             } = error
    end

    test "allows referencing by id" do
      assert {:ok, entity} = Builder.new(%{context: "https://moodle.net/group/1"})
      assert hd(entity.context) |> Entity.status() == :not_loaded
    end

    test "builds actors" do
      params = %{
        type: "Person",
        name: "Alex",
        preferred_username: "alexcastano",
      }
      assert {:ok, entity} = Builder.new(params)
      assert %{
        preferred_username: "alexcastano",
        type: ["Object", "Actor", "Person"],
        name: %{"und" => "Alex"}
      } = entity
    end

    test "builds activity" do
      params = %{
        "@context": "https://www.w3.org/ns/activitystreams",
        type: "Create",
        to: ["https://chatty.example/ben/"],
        actor: "https://social.example/alyssa/",
        object: %{
          type: "Note",
          attributedTo: "https://social.example/alyssa/",
          to: ["https://chatty.example/ben/"],
          content: "Say, did you finish reading that book I lent you?"
        }
      }
      assert {:ok, entity} = Builder.new(params)
      # TODO
      assert %{} = entity
    end

    @tag :skip
    test "builds plain objects" do
      map = %{
        attributed_to: [
          %{
            id: "https://alex.gitlab.com",
            type: "Person",
            name: "Alex",
            inbox: "https://alex.gitlab.com/inbox",
            outbox: "https://alex.gitlab.com/outbox"
          },
          "https://doug.gitlab.com"
        ],
        type: "Object",
        content: "This is a content",
        name: "This is my name",
        end_time: "2015-01-01T06:00:00-08:00",
        new_field: "extra",
        url: "https://alex.gitlab.com/profile"
      }

      assert {:ok, entity} = Entity.parse(map)
      assert entity.content == %{"und" => map.content}
      assert entity.name == %{"und" => map.name}

      assert %DateTime{
               year: 2015,
               month: 1,
               day: 1,
               hour: 14,
               minute: 0,
               second: 0
             } = entity.end_time

      assert entity["new_field"] == map.new_field
      assert entity[:url] == [map.url]

      assert hd(entity.attributed_to)["inbox"] == "https://alex.gitlab.com/inbox"
    end
  end
end
