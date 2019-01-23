defmodule MoodleNetWeb.GraphQL.Errors do
  import MoodleNetWeb.Gettext

  def handle_error({:error, _, error, _}),
    do: handle_error({:error, error})

  def handle_error({:error, %Ecto.Changeset{} = ch}),
    do: changeset_error(ch)

  def handle_error({:error, :not_found}),
    do: not_found_error()

  def handle_error({:error, {:not_found, value, type}}),
    do: not_found_error(value, type)

  def handle_error({:error, :unauthorized}),
    do: unauthorized_error()

  def handle_error({:error, :forbidden}),
    do: forbidden_error()

  def handle_error({:error, code}) when is_binary(code) or is_atom(code),
    do: unknown_error(code)

  def handle_error(ret), do: ret

  def changeset_error(%Ecto.Changeset{} = changeset) do
    errors =
      Enum.map(changeset.errors, fn {field, {msg, opts}} ->
        message = changeset_error_msg(msg, opts)

        extra =
          Map.new(opts)
          |> Map.put(:field, field)

        %{
          code: :validation,
          message: message,
          extra: extra
        }
      end)

    {:error, errors}
  end

  defp changeset_error_msg(msg, opts) do
    if count = opts[:count] do
      Gettext.dngettext(MoodleNetWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MoodleNetWeb.Gettext, "errors", msg, opts)
    end
  end

  def not_found_error() do
    {:error,
     %{
       message: gettext("not found"),
       code: :not_found
     }}
  end

  def not_found_error(value, type) do
    human_type = human_type(type)
    msg = "#{human_type} #{gettext("not found")}"

    {:error,
     %{
       extra: %{value: value, type: type},
       message: msg,
       code: :not_found,
     }}
  end

  def bad_gateway_error() do
    {:error,
      %{
        message: gettext("An error happened connecting with an external server"),
        code: :bad_gateway
      }
    }
  end

  def invalid_credential_error() do
        {:error, %{
          code: :unathorized,
          message: gettext("Invalid credentials"),
        }}
  end

  def unauthorized_error() do
    {:error,
     %{
       message: gettext("You need to log in first"),
       code: :unauthorized
     }}
  end

  def forbidden_error() do
    {:error,
     %{
       message: gettext("You are not authorized to perform this action"),
       code: :forbidden
     }}
  end

  def unknown_error(code) do
    {:error,
     %{
       message: gettext("There was an unknown error"),
       code: code
     }}
  end

  defp human_type(nil),
    do: gettext("Object")

  defp human_type("Actor"),
    do: gettext("User")

  defp human_type("MoodleNet:Community"),
    do: gettext("Community")

  defp human_type("MoodleNet:Collection"),
    do: gettext("Collection")

  defp human_type("MoodleNet:EducationalResource"),
    do: gettext("Resource")

  defp human_type("Note"),
    do: gettext("Comment")

  defp human_type("Context"),
    do: gettext("Context")

  defp human_type("Activity"),
    do: gettext("Activity")

  defp human_type("Token"),
    do: gettext("Token")

  defp human_type(ret), do: ret
end
