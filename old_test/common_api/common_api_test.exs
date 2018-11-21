defmodule MoodleNetWeb.CommonAPI.Test do
  use MoodleNet.DataCase
  alias MoodleNetWeb.CommonAPI
  alias MoodleNet.Accounts.User
  alias MoodleNetWeb.Endpoint
  alias MoodleNet.Builders.{UserBuilder}

  import MoodleNet.Factory

  test "it de-duplicates tags" do
    user = insert(:user)
    {:ok, activity} = CommonAPI.post(user, %{"status" => "#2hu #2HU"})

    assert activity.data["object"]["tag"] == ["2hu"]
  end

  test "it adds emoji when updating profiles" do
    user = insert(:user, %{name: ":karjalanpiirakka:"})

    CommonAPI.update(user)
    user = User.get_cached_by_ap_id(user.ap_id)
    [karjalanpiirakka] = user.info["source_data"]["tag"]

    assert karjalanpiirakka["name"] == ":karjalanpiirakka:"
  end

  test "it adds attachment links to a given text and attachment set" do
    name =
      "Sakura%20Mana%20%E2%80%93%20Turned%20on%20by%20a%20Senior%20OL%20with%20a%20Temptating%20Tight%20Skirt-s%20Full%20Hipline%20and%20Panty%20Shot-%20Beautiful%20Thick%20Thighs-%20and%20Erotic%20Ass-%20-2015-%20--%20Oppaitime%208-28-2017%206-50-33%20PM.png"

    attachment = %{
      "url" => [%{"href" => name}]
    }

    res = CommonAPI.add_attachments("", [attachment])

    assert res ==
             "<br><a href=\"#{name}\" class='attachment'>Sakura Mana – Turned on by a Se…</a>"
  end

  describe "it confirms the password given is the current users password" do
    test "incorrect password given" do
      {:ok, user} = UserBuilder.insert()

      assert CommonAPI.confirm_current_password(user, "") == {:error, "Invalid password."}
    end

    test "correct password given" do
      {:ok, user} = UserBuilder.insert()
      assert CommonAPI.confirm_current_password(user, "test") == {:ok, user}
    end
  end

  test "parses emoji from name and bio" do
    {:ok, user} = UserBuilder.insert(%{name: ":karjalanpiirakka:", bio: ":perkele:"})

    expected = [
      %{
        "type" => "Emoji",
        "icon" => %{"type" => "Image", "url" => "#{Endpoint.url()}/finmoji/128px/perkele-128.png"},
        "name" => ":perkele:"
      },
      %{
        "type" => "Emoji",
        "icon" => %{
          "type" => "Image",
          "url" => "#{Endpoint.url()}/finmoji/128px/karjalanpiirakka-128.png"
        },
        "name" => ":karjalanpiirakka:"
      }
    ]

    assert expected == CommonAPI.emoji_from_profile(user)
  end
end
