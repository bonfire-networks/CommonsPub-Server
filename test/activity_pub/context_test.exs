defmodule ActivityPub.ContextTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.{Context, ParseError}

  describe "parse" do
    test "works with nil" do
      assert {:ok, %Context{}} == Context.parse(nil)
    end

    test "works with maps" do
      map = %{
        "@vocab" => "https://www.w3.org/ns/activitystreams",
        "ext" => "https://canine-extension.example/terms/",
        "@language" => "en"
      }

      assert {:ok, value} = Context.parse(map)

      assert value == %Context{
               language: "en",
               values: [
                 {"ext", "https://canine-extension.example/terms/"},
                 {"@vocab", "https://www.w3.org/ns/activitystreams"}
               ]
             }
    end

    test "works with strings" do
      assert {:ok, value} = Context.parse("https://www.w3.org/ns/activitystreams")

      assert value == %Context{
               language: "und",
               values: ["https://www.w3.org/ns/activitystreams"]
             }
    end

    test "works with combination" do
      param = [
        "https://www.w3.org/ns/activitystreams",
        %{
          "css" => "http://www.w3.org/ns/oa#styledBy"
        }
      ]

      assert {:ok, value} = Context.parse(param)

      assert value == %Context{
               language: "und",
               values: [
                 {"css", "http://www.w3.org/ns/oa#styledBy"},
                 "https://www.w3.org/ns/activitystreams"
               ]
             }
    end

    test "returns errors" do
      assert {:error, %ParseError{
        message: "is invalid",
        value: true,
        key: "@context"
      }} = Context.parse(true)
    end

    # FIXME
    @tag :skip
    test "complex case" do
      param = [
        "https://www.w3.org/ns/activitystreams",
        %{
          "oa" => "http://www.w3.org/ns/oa#",
          "prov" => "http://www.w3.org/ns/prov#",
          "dcterms" => "http://purl.org/dc/terms/",
          "dcterms:created" => %{
            "@id" => "dcterms:created",
            "@type" => "xsd:dateTime"
          }
        }
      ]
      assert {:ok, _value} = Context.parse(param)
    end
  end
end
