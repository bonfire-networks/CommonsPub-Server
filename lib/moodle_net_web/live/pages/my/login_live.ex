defmodule MoodleNetWeb.LoginLive do
  use MoodleNetWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       app_name: Application.get_env(:moodle_net, :app_name),
       app_icon: Application.get_env(:moodle_net, :app_icon, "/images/sun_face.png"),
       instance_image: "https://i.ytimg.com/vi/_qzacv8dtb4/maxresdefault.jpg",
       app_summary: MoodleNet.Instance.description()
     )}
  end

  def render(assigns) do
    ~L"""
    <div class="page__login">
    <div class="standard__logo">
      <img src="<%=@app_icon%>" />
      <h1><%=@app_name%></h1>
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
        <div class="img" style="background-image: url('<%=@instance_image%>')" ></div>
        <div class="background__details">
          <h4>About this instance</h4>
          <p><%=@app_summary%></p>
        </div>
      </div>
    </div>
    <div class="login__footer"></div>
    </div>
    """
  end
end
