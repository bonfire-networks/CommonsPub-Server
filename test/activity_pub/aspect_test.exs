defmodule ActivityPub.AspectTest do
  use MoodleNet.DataCase
  alias ActivityPub.{LanguageValueType, Context}

  defmodule Foo do
    use ActivityPub.Aspect, persistence: :any

    aspect do
      field(:id, :string)
      field(:translatable, LanguageValueType)
      assoc(:url)
    end
  end

  test "define __aspect__(:fields)" do
    assert [:id, :translatable] == Foo.__aspect__(:fields)
  end

  test "define __aspect__(:associations)" do
    assert [:url] == Foo.__aspect__(:associations)
  end

  test "define __aspect__(:type, attr)" do
    assert :string == Foo.__aspect__(:type, :id)
  end

  describe "parse" do
    test "casts values" do
      params = %{"no_field" => "awesome", "id" => "any_id"}
      assert {:ok, parsed, rest_params} = Foo.parse(params, %Context{})
      assert parsed == %{id: "any_id", translatable: %{}, url: []}
      assert rest_params == %{"no_field" => "awesome"}
    end

    test "returns errors" do
      params = %{"no_field" => "awesome", "id" => 1}
      assert {:error, error} = Foo.parse(params, %Context{})
      assert %ActivityPub.ParseError{key: "id", message: "is invalid", value: 1} = error
    end

    test "works with translatable fields" do
      params = %{"translatable" => "string"}
      context = %Context{language: "es"}

      assert {:ok, parsed, %{}} = Foo.parse(params, context)
      assert %{translatable: %{"es" => "string"}} = parsed

      value = %{"en" => "string", "fr" => "string"}
      params = %{"translatable_map" => value}
      assert {:ok, parsed, %{}} = Foo.parse(params, context)
      assert %{id: nil, translatable: ^value} = parsed
    end
  end

  # Errors
  test "field name clash" do
    assert_raise ArgumentError, "field/association :name is already set on aspect", fn ->
      defmodule AspectFieldNameClash do
        use ActivityPub.Aspect, persistence: :any

        aspect do
          field(:name, :string)
          field(:name, :integer)
        end
      end
    end
  end

  test "invalid field type" do
    assert_raise ArgumentError, "invalid or unknown type {:apa} for field :name", fn ->
      defmodule AspectInvalidFieldType do
        use ActivityPub.Aspect, persistence: :any

        aspect do
          field(:name, {:apa})
        end
      end
    end

    assert_raise ArgumentError, "invalid or unknown type OMG for field :name", fn ->
      defmodule AspectInvalidFieldType do
        use ActivityPub.Aspect, persistence: :any

        aspect do
          field(:name, OMG)
        end
      end
    end

    regex = ~r/schema ActivityPub.AspectTest.FooSchema is not a valid type for field :name/

    assert_raise ArgumentError, regex, fn ->
      defmodule FooSchema do
        use Ecto.Schema

        embedded_schema do
          field(:string)
        end
      end

      defmodule AspectInvalidFieldType do
        use ActivityPub.Aspect, persistence: :any

        aspect do
          field(:name, FooSchema)
        end
      end
    end
  end
end
