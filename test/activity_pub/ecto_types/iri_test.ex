defmodule ActivityPub.IRITest do
  use ExUnit.Case, async: true

  test "validate" do
    assert ActivityPub.validate_id(nil) == {:error, :not_string}

    assert ActivityPub.validate_id("social.example") == {:error, :invalid_scheme}

    assert ActivityPub.validate_id("https://") == {:error, :invalid_host}

    assert ActivityPub.validate_id("https://social.example/") == {:error, :invalid_path}

    assert ActivityPub.validate_id("https://social.example/alyssa") == :ok
  end
end
