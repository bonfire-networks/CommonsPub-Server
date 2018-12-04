defmodule ActivityPubWeb.MRF do
  @callback filter(Map.t()) :: {:ok | :reject, Map.t()}

  # https://git.moodle_net.social/moodle_net/moodle_net/wikis/Message-Rewrite-Facility-configuration-(how-to-block-instances)
  #
  # Doc from the wiki:
  #
  # > The Message Rewrite Facility (MRF) is a subsystem that is implemented
  # > as a series of hooks that allows the administrator to rewrite or discard messages.
  #
  # This is really interesting, it can help to the server admin to:
  #   * Filter spam
  #   * Content no wanted by like porn or racist messages
  #
  # I'm not a big of changing the content. I prefer to reject.
  # I can understand add a tag like #nsfw, but you lose credibility as a hoster.
  # People cannot trust the content you serve.
  #
  # We should also add a property (not standard of course),
  # to say if the content was modified by the server.
  # This way we can alert other server to fetch the original content
  # (if they can, sometimes private content is possible)
  # and they can apply their own filters.
  # Client apps can also use this property to alert the user this content has been modified
  #
  # If we implement Linked-Data signatures: https://w3c-dvcg.github.io/ld-signatures/
  # clients and servers can verify the authority of the author.
  # (as long as the private key is only stored in the client app)
  # Disclaimer: not an expert :P
  def filter(object) do
    # This code runs in runtime,
    # it can be done in compilation time to go faster!
    get_policies()
    |> Enum.reduce({:ok, object}, fn
      policy, {:ok, object} ->
        policy.filter(object)

      _, error ->
        error
    end)
  end

  def get_policies() do
    Application.get_env(:moodle_net, :instance, [])
    |> Keyword.get(:rewrite_policy, [])
    |> get_policies()
  end

  defp get_policies(policy) when is_atom(policy), do: [policy]
  defp get_policies(policies) when is_list(policies), do: policies
  # This should crash instead of return a "default object".
  # If the admin of the site is defining a wrong option
  # the apps will work but the policies were never applied.
  # If we crash here, the admin is notified that the conf is wrong
  # so he has the possibility to fix it
  defp get_policies(_), do: []
end
