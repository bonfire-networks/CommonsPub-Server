defmodule MoodleNetWeb.ChangesetView do
  use MoodleNetWeb, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `MoodleNetWeb.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("conflict.json", %{changeset: %{data: %{__struct__: struct_name}}}) do
    model_name = struct_name
                 |> Module.split
                 |> List.last
    %{
      error_message: "#{model_name} is already created",
      error_code: "conflict"
    }
  end

  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{
      # TODO error_info: with standarized way to show validation errors
      errors: translate_errors(changeset),
      error_message: "Validation errors",
      error_code: "validation_errors"
    }
  end
end
