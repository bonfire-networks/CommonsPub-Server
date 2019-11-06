defmodule MoodleNetWeb.GraphQL.CommentsResolver do

  alias MoodleNet.{Comments}
  

  def fetch(%{comment_id: comment_id}, info) do
  end

  def create_thread(%{context_id: context_id, comment: attrs}, info) do
  end

  def create_reply(%{in_reply_to_id: in_reply_to_id, comment: attrs}, info) do
  end

  def update(%{comment_id: comment_id, comment: changes}, info) do
  end

  # def delete_thread(%{thread_id: id}, info) do
  # end

  def delete_comment(%{comment_id: id}, info) do
  end

end
