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

# for _ <- 1..10 do
#   comm = fake_community!(admin)
#   for _ <- 1..10 do
#     coll = fake_collection!(admin, comm)
#     for _ <- 1..10 do
#       fake_resource!(admin, coll)
#     end
#   end
# end
