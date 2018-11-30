defmodule MoodleNetWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use MoodleNetWeb, :controller

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(MoodleNetWeb.ErrorView)
    |> render("403.json")
  end

  def call(conn, {:error, {:unauthorized, msg}}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(MoodleNetWeb.ErrorView)
    |> render("401.json", %{message: msg})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(MoodleNetWeb.ErrorView)
    |> render("401.json")
  end

  def call(conn, {
        :error,
        %Ecto.Changeset{
          errors: [primary_key: _]
        } = changeset
      }) do
    conn
    |> put_status(:conflict)
    |> put_view(MoodleNetWeb.ChangesetView)
    |> render("conflict.json", changeset: changeset)
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(MoodleNetWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # For Multi fails
  def call(conn, {:error, _, error, _}) do
    call(conn, {:error, error})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(MoodleNetWeb.ErrorView)
    |> render("404.json")
  end

  def call(conn, {:error, {:not_found, key}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: %{key => "does not exist"}})
  end

  def call(conn, {:error, {:missing_param, key}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(MoodleNetWeb.ErrorView)
    |> render("missing_param.json", %{key: key})
  end

  def call(conn, {:error, {status, error}})
      when (is_integer(status) or is_atom(status)) and (is_atom(error) or is_binary(error)) do
    conn
    |> put_status(status)
    |> json(%{error_message: to_string(error)})
  end

  def call(conn, {:error, {status, error, error_code}})
      when (is_integer(status) or is_atom(status)) and (is_atom(error) or is_binary(error)) and is_binary(error_code) do
    conn
    |> put_status(status)
    |> json(%{error_message: to_string(error), error_code: error_code})
  end
end
