defmodule MoodleNetWeb.SettingsLive.SettingsInvitesLive do
  use MoodleNetWeb, :live_component


def render(assigns) do
  ~L"""
  <section class="settings__section">
      <div class="section__main">
        <h1>Manage your instance registration</h1>
        <form action="#" phx-submit="post">
          <div class="section__item">
            <h4>Email</h4>
            <input name="name" type="text" placeholder="Add email addresses (comma-separated) to invite to instance">
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
