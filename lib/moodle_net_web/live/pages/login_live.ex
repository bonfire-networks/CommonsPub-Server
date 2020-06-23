defmodule MoodleNetWeb.LoginLive do
  use MoodleNetWeb, :live_view

  def mount(socket) do
    {:ok, assign(socket, :name, "Ivan")}
  end

  def render(assigns) do
    ~L"""
    <div class="page__login">
    <div class="standard__logo">
      <img src="./images/sun_face.png" />
      <h1>The Roots plays good shit.</h1>
    </div>
    <div class="login__form">
      <div class="form__wrapper">
        <form>
          <input type="text" placeholder="Type your username..." />
          <input type="password" placeholder="Type your password..." />
          <button type="submit">Sign in</button>
        </form>
        <a href="#">Trouble logging in?</a>
      </div>
    </div>
    <div class="login__signup">
      <a href="#">Sign up</a>
      <div class="signup__background">
        <div class="img" style="background-image: url('https://i.ytimg.com/vi/_qzacv8dtb4/maxresdefault.jpg')" ></div>
        <div class="background__details">
          <h4>Instance description</h4>
          <p>This general-purpose instance of MoodleNet is run by Moodle HQ and is part of the wider network.</p>
        </div>
      </div>
    </div>
    <div class="login__footer"></div>
  </div>
    """
  end
end
