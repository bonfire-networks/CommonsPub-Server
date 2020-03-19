alias MoodleNet, as: MN
alias MoodleNetWeb, as: MNW
alias MoodleNet.{
  Access,
  Activities,
  Actors,
  Blocks,
  Collections,
  Common,
  Communities,
  Features,
  Feeds,
  Flags,
  Follows,
  GraphQL,
  Instance,
  Likes,
  Localisation,
  Mail,
  Meta,
  Peers,
  Repo,
  Resources,
  Tags,
  Threads,
  Users,
  Workers,
}
alias MoodleNet.Meta.Pointers
alias MoodleNet.Threads.Comments
import MoodleNet.Test.Faking
IO.puts("[.iex.exs] aliased {MN, MNW, MN.*, MNW.*}\n")
