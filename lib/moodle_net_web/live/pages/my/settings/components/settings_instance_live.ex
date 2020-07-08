defmodule MoodleNetWeb.SettingsLive.SettingsInstanceLive do
  use MoodleNetWeb, :live_component
  import MoodleNetWeb.Helpers.Common


def render(assigns) do
  ~L"""
  <section class="settings__section">
      <div class="section__main">
        <h1>Customize your instance</h1>
        <form action="#" phx-submit="post">
          <div class="section__item">
            <h4>Add domain to allowlist</h4>
            <input name="name" type="text" placeholder="Enter domain (e.g. riseup.org)">
          </div>
          <div class="section__actions">
            <button type="submit" phx-disable-with="Updating...">Update</button>
          </div>
      </form>
      </div>
    </section>
  """
end
end
