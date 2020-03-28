# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.ErrorViewTest do
  use MoodleNetWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(MoodleNetWeb.ErrorView, "404.json", []) == %{
             error_code: "not_found",
             error_message: "Not found"
           }
  end

  test "render 500.json" do
    assert render(MoodleNetWeb.ErrorView, "500.json", []) == %{
             error_code: "internal_server_error",
             error_message: "Internal server error"
           }
  end

  test "render any other" do
    assert render(MoodleNetWeb.ErrorView, "505.json", []) == %{
             error_code: "internal_server_error",
             error_message: "Internal server error"
           }
  end
end
