# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Web.ErrorView do
  use CommonsPub.Web, :view

  def render("400.json", _assigns) do
    %{error_message: "Bad request", error_code: "bad_request"}
  end

  def render("401.json", %{message: message}) do
    %{error_message: message, error_code: "unauthorized"}
  end

  def render("401.json", _assigns) do
    %{error_message: "Invalid credentials", error_code: "unauthorized"}
  end

  def render("403.json", _assigns) do
    %{error_message: "Not allowed", error_code: "forbidden"}
  end

  def render("404.json", _assigns) do
    %{error_message: "Not found", error_code: "not_found"}
  end

  def render("500.json", _) do
    %{error_message: "Internal server error", error_code: "internal_server_error"}
  end

  def render("missing_param.json", %{key: key}) do
    %{error_message: "Param not found: #{key}", error_code: "missing_param"}
  end

  def render("bad_gateway.json", %{error: error}) do
    %{error_message: error, error_code: "bad_gateway"}
  end

  def render("500.html", _) do
    "Something was wrong"
    # render(CommonsPub.Web.ErrorView, "internal_server_error.html")
  end

  def render("404.html", assigns) do
    assigns = Map.merge(assigns, %{layout: {CommonsPub.Web.LayoutView, "app.html"}})
    render(CommonsPub.Web.ErrorView, "not_found.html", assigns)
  end

  @doc """
    In case no render clause matches or no template is found, let's render it as 500
  """
  def template_not_found(template, assigns) do
    if String.ends_with?(template, "json") do
      render("500.json", assigns)
    else
      render("500.html", assigns)
    end
  end
end
