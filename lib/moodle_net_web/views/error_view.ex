defmodule MoodleNetWeb.ErrorView do
  use MoodleNetWeb, :view

  @error_400 %{errors: %{detail: "Page not found"}} |> Jason.encode!()
  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}} |> Jason.encode!()
  end

  @error_500 %{errors: %{detail: "Internal server error"}} |> Jason.encode!()
  def render("500.json", _assigns) do
    @error_500
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.json", assigns)
  end
end
