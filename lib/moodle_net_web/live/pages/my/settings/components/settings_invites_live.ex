defmodule MoodleNetWeb.SettingsLive.SettingsInvitesLive do
  use MoodleNetWeb, :live_component

  def render(assigns) do
    ~L"""
    <section class="settings__section">
        <div class="section__main">
          <h1>Manage your instance registration</h1>
          <form action="#" phx-submit="invite">
            <div class="section__item">
              <h4>Email</h4>
              <input name="email" type="text" placeholder="Email address of someone to invite to this instance">
            </div>
            <div class="section__actions">
              <button type="submit" phx-disable-with="Sending...">Invite</button>
            </div>
        </form>
        </div>
      </section>
    """
  end
end
