defmodule MoodleNet.ActivityPub.Publisher do
  alias MoodleNet.ActivityPub.Utils

  # FIXME: this will break if parent is an object that isn't in AP database or doesn't have a pointer_id filled
  def comment(comment) do
    with {:ok, parent} <- MoodleNet.Meta.follow(comment.thread.parent),
         parent_id <- Utils.get_parent_id(parent),
         {:ok, actor} <- ActivityPub.Actor.get_by_username(comment.creator.preferred_username),
         {to, cc} <- Utils.determine_recipients(actor, parent),
         object <- %{
           "content" => comment.current.content,
           "to" => to,
           "cc" => cc,
           "actor" => actor.ap_id,
           "attributedTo" => actor.ap_id
         },
         params <- %{
           actor: actor,
           to: to,
           object: object,
           context: parent_id,
           additional: %{
             "cc" => cc
           }
         } do
      #FIXME: pointer_id isn't getting inserted for whatever reason
      ActivityPub.create(params, comment.id)
    else
      _e -> :error
    end
  end

  @spec run(Map.t()) :: :ok | {:error, any()}
  def run(_map) do
    :ok
  end
end
