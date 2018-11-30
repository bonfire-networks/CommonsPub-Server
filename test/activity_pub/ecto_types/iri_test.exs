defmodule ActivityPub.IRITest do
  use ExUnit.Case, async: true

  alias ActivityPub.IRI

  test "validate" do
    assert IRI.validate(nil) == {:error, :not_string}

    assert IRI.validate("social.example") == {:error, :invalid_scheme}

    assert IRI.validate("https://") == {:error, :invalid_host}

    assert IRI.validate("https://social.example/") == :ok

    assert IRI.validate("https://social.example/alyssa") == :ok
  end
end
