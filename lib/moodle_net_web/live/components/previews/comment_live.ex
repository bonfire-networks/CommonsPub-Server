defmodule MoodleNetWeb.Component.CommentPreviewLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="comment__preview">
      <div class="markdown-body">
      There are numerous <b>success stories</b> you will hear <i>about</i> businesses making it good on the internet . The troubling thing is, there are maybe a tenfold or even a hundredfold of stories inconsistent to theirs. Many have unsuccessfully launched a business venture that is internet based but only a handful shall succeed.
      </div>
    </div>
    """
  end
end
