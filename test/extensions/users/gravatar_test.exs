# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Users.GravatarTest do
  use CommonsPub.DataCase, async: true

  alias CommonsPub.Users.Gravatar

  test "works" do
    assert "https://s.gravatar.com/avatar/7779b850ea05dbeca7fc39a910a77f21?d=retro&r=g&s=80" ==
             Gravatar.url("alex@moodle.com")
  end
end
