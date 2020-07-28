defmodule MoodleNetWeb.SettingsLive.SettingsGeneralLive do
  use MoodleNetWeb, :live_component
  import MoodleNetWeb.Helpers.Common

  def render(assigns) do
    ~L"""
    <section class="settings__section">
        <div class="section__main">
          <h1>My profile</h1>
          <form action="/~/settings" phx-submit="profile_save" method="post" enctype="multipart/form-data" <%= if @trigger_submit, do: "phx-trigger-action" %>>
            <div class="section__item">
            <h4>Edit your background image</h4>
            <label class="file">
            <img src="<%= e(@current_user, :image_url, "") %>" style="width:50px; height:auto" />
            <input name="image[upload]" type="file" id="image" aria-label="Image file selector" phx-update="ignore">
              <span class="file-custom"></span>
            </label>
          </div>
          <div class="section__item">
            <h4>Edit your avatar</h4>
            <label class="file">
              <img src="<%= e(@current_user, :icon_url, "") %>" style="width:50px; height:auto" />
              <input name="icon[upload]" type="file" id="icon" aria-label="Icon file selector" phx-update="ignore">
              <span class="file-custom"></span>
            </label>
          </div>
          <div class="section__item">
            <h4>Edit your name</h4>
            <input name="profile[name]" type="text" value="<%= @current_user.name %>" placeholder="Type a new name...">
          </div>
          <div class="section__item">
          <h4>Edit your email</h4>
              <input name="profile[email]" value="<%= @current_user.local_user.email %>" type="text" placeholder="Type a new email...">
          </div>
          <div class="section__item">
          <h4>Edit your website</h4>
              <input name="profile[website]" value="<%= @current_user.website %>" type="text" placeholder="Type a new website...">
          </div>
          <div class="section__item">
          <h4>Edit your location</h4>
              <input name="profile[location]" type="text" value="<%= @current_user.location %>" placeholder="Type a new location...">
          </div>
          <div class="section__item">
          <h4>Edit your summary</h4>
              <textarea name="profile[summary]" placeholder="Type your summary..."><%= @current_user.summary %></textarea>
          </div>

          <div class="section__actions">
           <input type="hidden" name="_csrf_token" value="<%= @csrf_token %>"/>
            <button type="submit" phx-disable-with="Updating...">Update</button>
          </div>
        </form>
        </div>
      </section>
    """
  end
end
