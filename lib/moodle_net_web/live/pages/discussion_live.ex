defmodule MoodleNetWeb.DiscussionLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.Component.HeaderLive
  alias MoodleNetWeb.Component.ActivityLive

  def render(assigns) do
    ~L"""
    <div class="page">
      <%= live_component(
          @socket,
          HeaderLive
        )
      %>
      <section class="page__wrapper">
        <div class="wrapper__discussion">
          <div class="discussion__hero">
            <div class="hero__head">
              <h1 class="head__title">Do we really need Motivational Design ?</h1>
              <div class="head__meta">
                <div class="meta__status">Open</div>
                <div class="meta__info">
                  17 Comments - 29 Starred
                </div>
              </div>
            </div>
            <div class="head__mainComment">
              <%= live_component(
                  @socket,
                  ActivityLive
                )
              %>
            </div>
          </div>
          <div class="discussion__replies">
            <%= live_component(
              @socket,
              ActivityLive
            )
            %>
            <%= live_component(
              @socket,
              ActivityLive
            )
            %>
            <%= live_component(
                @socket,
                ActivityLive
              )
            %>
            <%= live_component(
              @socket,
              ActivityLive
            )
            %>
            <div class="discussion__reply">
              <img src="https://home.next.moodle.net/uploads/01E9TQEVAKAVNZCQVE94NJA7TP/moebius4.jpeg" alt="logged icon" />
              <div class="reply__box">
                <textarea placeholder="Add a reply"></textarea>
                <button>Comment</button>
              </div>
            </div>
          </div>
        </div>
      </section>
      </div>

    """
  end
end
