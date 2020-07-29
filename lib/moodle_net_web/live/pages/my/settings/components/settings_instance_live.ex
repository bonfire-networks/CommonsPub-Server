defmodule MoodleNetWeb.SettingsLive.SettingsInstanceLive do
  use MoodleNetWeb, :live_component

  # import MoodleNetWeb.Helpers.Common

  def render(assigns) do
    ~L"""
    <section class="settings__section">
        <div class="section__main">
          <h1>Customize your instance</h1>
          <form action="#" phx-submit="add-domain">
            <div class="section__item">
              <h4>Allow anyone to sign up who has an email address from a particular domain</h4>
              <input name="domain" type="text" placeholder="Enter domain (e.g. riseup.org)">
            </div>
            <div class="section__actions">
              <button type="submit" phx-disable-with="Saving...">Add</button>
            </div>
        </form>
        </div>
      </section>
    """
  end
end
