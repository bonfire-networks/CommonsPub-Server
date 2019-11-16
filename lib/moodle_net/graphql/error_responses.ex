alias MoodleNet.GraphQL.Response
alias MoodleNet.Common.{
  AlreadyFlaggedError,
  AlreadyFollowingError,
  AlreadyLikedError,
  DeletionError,
  NotFlaggableError,
  NotFollowableError,
  NotFoundError,
  NotLikeableError,
  NotLoggedInError,
  NotPermittedError,
}
  # def changeset_error(%Ecto.Changeset{} = changeset) do
  #   errors =
  #     Enum.map(changeset.errors, fn {field, {msg, opts}} ->
  #       message = changeset_error_msg(msg, opts)

  #       extra =
  #         Map.new(opts)
  #         |> Map.put(:field, field)

  #       %{
  #         code: :validation,
  #         message: message,
  #         extra: extra
  #       }
  #     end)

  #   {:error, errors}
  # end

  # defp changeset_error_msg(msg, opts) do
  #   if count = opts[:count] do
  #     Gettext.dngettext(MoodleNetWeb.Gettext, "errors", msg, msg, count, opts)
  #   else
  #     Gettext.dgettext(MoodleNetWeb.Gettext, "errors", msg, opts)
  #   end
  # end

defimpl Response, for: AlreadyFlaggedError do
  def to_response(_self, _info, _path) do
    %{message: "already flagged", code: "already_flagged", status: 409}
  end
end

defimpl Response, for: AlreadyFollowingError do
  def to_response(_self, _info, _path) do
    %{message: "already following", code: "already_following", status: 409}
  end
end

defimpl Response, for: AlreadyLikedError do
  def to_response(_self, _info, _path) do
    %{message: "already liked", code: "already_liked", status: 409}
  end
end

defimpl Response, for: DeletionError do
  def to_response(_self, _info, _path) do
    %{message: "delete failed", code: "delete_failed", status: 500}
  end
end

defimpl Response, for: NotFlaggableError do
  def to_response(_self, _info, _path) do
    %{message: "not flaggable", code: "not_flaggable", status: 403}
  end
end

defimpl Response, for: NotFollowableError do
  def to_response(_self, _info, _path) do
    %{message: "not followable", code: "not_followable", status: 403}
  end
end

defimpl Response, for: NotLikeableError do
  def to_response(_self, _info, _path) do
    %{message: "not likeable", code: "not_likeable", status: 403}
  end
end

defimpl Response, for: NotFoundError do
  def to_response(_self, _info, _path) do
    %{message: "not found", code: "not_found", status: 404}
  end
end

defimpl Response, for: NotLoggedInError do
  def to_response(_self, _info, _path) do
    %{message: "You need to log in first.", code: "unauthorized", status: 403}
  end
end

defimpl Response, for: NotPermittedError do
  def to_response(_self, _info, _path) do
    %{message: "You do not have permission to see this.", code: "unauthorized", status: 403}
  end
end
