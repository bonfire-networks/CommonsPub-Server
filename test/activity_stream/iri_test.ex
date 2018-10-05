defmodule ActivityStream.IRITest do
  use ExUnit.Case, async: true

  test "validate" do
    assert ActivityStream.validate_id(nil) == {:error, :not_string}

    assert ActivityStream.validate_id("social.example") == {:error, :invalid_scheme}

    assert ActivityStream.validate_id("https://") == {:error, :invalid_host}

    assert ActivityStream.validate_id("https://social.example/") == {:error, :invalid_path}

    assert ActivityStream.validate_id("https://social.example/alyssa") == :ok
  end
end
