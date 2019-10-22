alias MoodleNet.GraphQL.Response
alias MoodleNet.Common.{
  NotFoundError,
  NotLoggedInError,
  NotPermittedError,
}

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
