defmodule MoodleNetWeb.WriteLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.Component.HeaderLive

  def mount(socket) do
    {:ok, assign(socket, :name, "Ivan")}
  end

  def render(assigns) do
    ~L"""
    <div class="page">
      <%= live_component(
          @socket,
          HeaderLive,
          icon: "https://home.next.moodle.net/uploads/01E9TQEVAKAVNZCQVE94NJA7TP/moebius4.jpeg"
        )
      %>
      <section class="page__wrapper">
        <div class="page__mainContent">
          <form class="mainContent_write">
              <input placeholder="Title" />
              <textarea placeholder="Tell your story"></textarea>
              <button>Submit</button>
            </form>
        </div>
      </section>
    </div>
    """
  end
end
