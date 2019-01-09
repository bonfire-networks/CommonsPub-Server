defmodule MoodleNet.EmailTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.Email

  test "welcome/2" do
    user = Factory.user()
    token = "this_is_the_token"
    email = Email.welcome(user, token)

    assert email.to == user.email
    assert email.html_body =~ token
    assert email.text_body =~ token
  end

  test "reset_password_request/2" do
    user = Factory.user()
    token = "this_is_the_token"
    email = Email.reset_password_request(user, token)

    assert email.to == user.email
    assert email.html_body =~ token
    assert email.text_body =~ token
  end

  test "password_reset/1" do
    user = Factory.user()
    email = Email.password_reset(user)

    assert email.to == user.email
  end
end
