defmodule MoodleNetWeb.Test.GraphQLAssertions do
  
  import ExUnit.Assertions

  def assert_location(loc) do
    assert %{"column" => col, "line" => line} = loc,
      "a location should have the correct keys"
    assert is_integer(col) and col >= 0,
      "a location column should be a nonzero integer"
    assert is_integer(line) and line >= 1,
      "a location line should be a positive integer"
  end

  def assert_unauthorized(errs, path) do
    assert [err] = errs,
      "unauthorized responses should contain *one* error"
    assert err["code"] == "unauthorized",
      "unauthorized responses should have an unauthorized code"
    assert err["message"] == "You need to log in first",
      "unauthorized responses should have the correct message"
    assert err["path"] == path,
      "unauthorized responses should have the correct path"
    assert [loc] = err["locations"],
      "unauthorized responses should have one location"
    assert_location(loc)
  end

end
