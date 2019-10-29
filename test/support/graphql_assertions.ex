defmodule MoodleNetWeb.Test.GraphQLAssertions do
  
  import ExUnit.Assertions

  def assert_location(loc) do
    assert %{"column" => col, "line" => line} = loc
    assert is_integer(col) and col >= 0
    assert is_integer(line) and line >= 1
  end

  def assert_not_logged_in(errs, path) do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => path2, "locations" => [loc]} = err
    assert code == "unauthorized"
    assert message == "You need to log in first."
    assert path == path2
    assert_location(loc)
  end

  def assert_not_permitted(errs, path) do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => ^path, "locations" => [loc]} = err
    assert code == "unauthorized"
    assert message == "You do not have permission to see this."
    assert_location(loc)
  end

  def assert_not_found(errs, path) do
    assert [err] = errs
    assert %{"code" => code, "message" => message} = err
    assert %{"path" => ^path, "locations" => [loc]} = err
    assert code == "not_found"
    assert message == "not found"
    assert_location(loc)
  end
end
