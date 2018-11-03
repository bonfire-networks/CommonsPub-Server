defmodule MoodleNet.Builders.UserBuilder do
  alias MoodleNet.{User, Repo}

  def build(data \\ %{}) do
    user = %User{
      email: "test@example.org",
      name: "Test Name",
      nickname: "testname",
      password_hash: Comeonin.Pbkdf2.hashpwsalt("test"),
      bio: "A tester.",
      ap_id: "some id"
    }

    Map.merge(user, data)
  end

  def insert(data \\ %{}) do
    {:ok, user} = Repo.insert(build(data))
    User.invalidate_cache(user)
    {:ok, user}
  end
end
