defmodule ActivityPub.UserViewTest do
  use MoodleNet.DataCase
  import MoodleNet.Factory
  alias MoodleNet.Accounts.User

  alias ActivityPub.UserView

  test "Renders a user, including the public key" do
    user = insert(:user)
    {:ok, user} = MoodleNet.Signature.ensure_keys_present(user)

    result = UserView.render("user.json", %{user: user})

    assert result["id"] == user.ap_id
    assert result["preferredUsername"] == user.nickname

    assert String.contains?(result["publicKey"]["publicKeyPem"], "BEGIN PUBLIC KEY")
  end
end
