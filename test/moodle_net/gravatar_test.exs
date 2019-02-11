defmodule MoodleNet.GravatarTest do
  use MoodleNet.DataCase, async: true

  test "works" do
    assert "https://s.gravatar.com/avatar/7779b850ea05dbeca7fc39a910a77f21?d=identicon&r=g&s=80" == MoodleNet.Gravatar.url("alex@moodle.com")
  end
end
