defmodule MoodleNetWeb.SignupLive do
  use MoodleNetWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       app_name: Application.get_env(:moodle_net, :app_name),
       app_icon: Application.get_env(:moodle_net, :app_icon, "/images/sun_face.png")
     )}
  end

  def render(assigns) do
    ~L"""
    <div class="page__signup">
    <div class="standard__logo">
      <img src="<%=@app_icon%>" />
      <h1><%=@app_name%></h1>
    </div>
    <div class="login__form">
      <div class="form__wrapper">
        <form>
          <div class="form__container">
            <label for="email">Email</label>
            <input id="email" type="text" placeholder="Type your email..." />
          </div>
          <div class="form__container">
            <label for="name">Full name</label>
            <input type="name" placeholder="Type your name..." />
          </div>
          <div class="form__container">
            <label for="username">Username</label>
            <input id="username" type="text" placeholder="Type your preferred username..." />
          </div>
          <div class="form__container">
            <label for="password">Password</label>
            <input id="password" type="password" placeholder="Type your password..." />
          </div>
          <div class="form__container">
            <label for="repeat-password">Password</label>
            <input id="repeat-password" type="password" placeholder="Repeat your password..." />
          </div>
          <button type="submit">Sign up</button>
        </form>
      </div>
    </div>
    <div class="login__footer"></div>
    </div>
    """
  end
end
