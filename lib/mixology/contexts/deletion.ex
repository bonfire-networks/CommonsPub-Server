defmodule CommonsPub.Contexts.Deletion do
  alias CommonsPub.Repo

  alias Bonfire.Common.Errors.DeletionError
  alias CommonsPub.Users.User

  require Logger

  @doc "Find and runs the soft_delete function in the context module based on object type. "
  def trigger_soft_delete(id, current_user) when is_binary(id) do
    with {:ok, pointer} <- Bonfire.Common.Pointers.one(id: id) do
      trigger_soft_delete(pointer, current_user)
    end
  end

  def trigger_soft_delete(%Pointers.Pointer{} = pointer, current_user) do
    context = Bonfire.Common.Pointers.follow!(pointer)
    trigger_soft_delete(context, current_user)
  end

  def trigger_soft_delete(%{} = context, true) do
    do_trigger_soft_delete(%{} = context, %User{})
  end

  def trigger_soft_delete(%{} = context, %{} = current_user) do
    if Bonfire.Repo.Delete.maybe_allow_delete?(current_user, context) do
      do_trigger_soft_delete(%{} = context, current_user)
    end
  end

  defp do_trigger_soft_delete(%{__struct__: object_type} = context, current_user) do
    with {:error, _e} <-
           CommonsPub.Contexts.run_context_function(
             object_type,
             :soft_delete,
             [current_user, context],
             &log_unable/2
           ) do
      CommonsPub.Contexts.run_context_function(
        object_type,
        :soft_delete,
        [context],
        &log_unable/2
      )
    end
  end

  def trigger_soft_delete(context, _, _) do

    log_unable(
      "Object to be deleted not recognised.",
      context
    )
  end


  defp log_unable(e, args) do
    error = "Unable to delete an object. #{e}"
    Logger.error("#{error} - args: #{inspect(args, pretty: true)}")
    Bonfire.Repo.Delete.deletion_result({:error, error})
  end

  # ActivityPub incoming Activity: Delete

  def ap_receive_activity(
        %{data: %{"type" => "Delete"}} = _activity,
        %{pointer_id: pointer_id} = _object
      )
      when is_binary(pointer_id) do
    with {:ok, _} <- Bonfire.Repo.Delete.trigger_soft_delete(pointer_id, true) do
      :ok
    end
  end

  def ap_receive_activity(
        %{data: %{"type" => "Delete"}} = _activity,
        %{} = delete_actor
      ) do
    # IO.inspect(delete: delete_actor)
    with {:ok, character} <-
           CommonsPub.ActivityPub.Utils.get_raw_character_by_ap_id(delete_actor),
         {:ok, _} <- Bonfire.Repo.Delete.trigger_soft_delete(character, true) do
      :ok
    else
      {:error, e} ->
        Logger.warn("Could not find character to delete")
        IO.inspect(delete_actor)
        IO.inspect(CommonsPub.ActivityPub.Utils.get_raw_character_by_ap_id(delete_actor))
        {:error, e}
    end
  end
end
