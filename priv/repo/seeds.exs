# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

import MoodleNet.Test.Faking

admin = %{
  email: "root@moodlenet.local",
  password: "password",
  preferred_username: "root",
  name: "root",
  is_instance_admin: true,
}
|> fake_user!(confirm_email: true)

users = for _ <- 1..10, do: fake_user!()
random_user = fn -> Faker.Util.pick(users) end
communities = for _ <- 1..4, do: fake_community!(random_user.())
for community <- communities do
  for _ <- 1..3 do # start a fake thread
    user = random_user.()
    thread = fake_thread!(user, community)
    comment = fake_comment!(user, thread)
    for _ <- 1..2 do # reply to it
      fake_comment!(random_user.(), thread, %{in_reply_to_id: comment.id})
    end
  end
  for _ <- 1..3 do # create a fake collection
    collection = fake_collection!(random_user.(), community)
    for _ <- 1..3 do # add some resources
      fake_resource!(random_user.(), collection)
    end
    for _ <- 1..3 do # start a fake thread
      user = random_user.()
      thread = fake_thread!(user, collection)
      comment = fake_comment!(user, thread)
      for _ <- 1..2 do # reply to it
        fake_comment!(random_user.(), thread, %{in_reply_to_id: comment.id})
      end
    end
  end
end
