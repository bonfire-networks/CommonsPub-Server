# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
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

for _ <- 1..4 do
  user = fake_user!()
  comm = fake_community!(user)
  for _ <- 1..5 do
    coll = fake_collection!(user, comm)
    for _ <- 1..3 do
      fake_resource!(user, coll)
    end
  end
end
