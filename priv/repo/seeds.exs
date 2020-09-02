# Generate some fake data and put it in the DB for testing/development purposes

import CommonsPub.Test.Faking

admin =
  %{
    email: "root@localhost.dev",
    preferred_username: System.get_env("SEEDS_USER", "root"),
    password: System.get_env("SEEDS_PW", "123456"),
    name: System.get_env("SEEDS_USER", "root"),
    is_instance_admin: true
  }
  |> fake_user!(confirm_email: true)

users = for _ <- 1..2, do: fake_user!()
random_user = fn -> Faker.Util.pick(users) end

# put content on user profiles
for user <- users do
  # start a fake thread
  for _ <- 1..2 do
    user = random_user.()
    thread = fake_thread!(user, nil)
    comment = fake_comment!(user, thread)
    # reply to it
    reply = fake_comment!(random_user.(), thread, %{in_reply_to_id: comment.id})
    subreply = fake_comment!(random_user.(), thread, %{in_reply_to_id: reply.id})
    subreply2 = fake_comment!(random_user.(), thread, %{in_reply_to_id: subreply.id})
  end

  # create fake collections
  for _ <- 1..2 do
    collection = fake_collection!(random_user.(), nil)
    # add some resources
    for _ <- 1..2 do
      fake_resource!(random_user.(), collection)
    end
  end
end

# start some communities
communities = for _ <- 1..2, do: fake_community!(random_user.())

# put content in communities
for community <- communities do
  # start a fake thread
  for _ <- 1..2 do
    user = random_user.()
    thread = fake_thread!(user, community)
    comment = fake_comment!(user, thread)
    # reply to it
    reply = fake_comment!(random_user.(), thread, %{in_reply_to_id: comment.id})
    subreply = fake_comment!(random_user.(), thread, %{in_reply_to_id: reply.id})
    subreply2 = fake_comment!(random_user.(), thread, %{in_reply_to_id: subreply.id})
  end

  # create fake collections within community
  for _ <- 1..2 do
    collection = fake_collection!(random_user.(), community)
    # add some resources
    for _ <- 1..2 do
      fake_resource!(random_user.(), collection)
    end

    # start a fake thread
    for _ <- 1..2 do
      user = random_user.()
      thread = fake_thread!(user, collection)
      comment = fake_comment!(user, thread)
      # reply to it
      # reply = fake_comment!(random_user.(), thread, %{in_reply_to_id: comment.id})
    end
  end

  if(Code.ensure_loaded?(Geolocation.Simulate)) do
    Geolocation.Simulate.fake_geolocation!(random_user.(), community)
  end

  if(Code.ensure_loaded?(Measurement.Simulate)) do
    unit = Measurement.Simulate.fake_unit!(random_user.(), community)

    if(Code.ensure_loaded?(ValueFlows.Simulate)) do
      intent = ValueFlows.Simulate.fake_intent!(random_user.(), unit)
    end
  end
end
