// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
// import "../css/app.scss";
import "../../lib/forkable/_styles.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket, debug } from "phoenix_live_view";
// import "easy-toggle-state"

let Hooks = {};

Hooks.TagPick = {
  mounted() {
    console.log("TagPick mounted");
    this.el.addEventListener("click", (e) => {
      console.log("tag clicked");
      var prefix = this.el.dataset.prefix || "@";
      var f = document.getElementById(this.el.dataset.target || "content");
      var dropdown =
        this.el.parentNode.parentNode || document.getElementById("write_tag");
      var ta = f.value.split(prefix);
      ta.pop();
      ta.push(this.el.dataset.tag + " "); // terminate with space
      f.value = ta.join(prefix);
      dropdown.innerHTML = "";
    });
  },
};

// let scrollAt = () => {
//   let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
//   let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
//   let clientHeight = document.documentElement.clientHeight

//   return scrollTop / (scrollHeight - clientHeight) * 100
// }

// Hooks.InfiniteScroll = {
//   page() {
//     return this.el.dataset.page
//   },
//   mounted(){
//     console.log(this.el)
//     this.pending = this.page()
//     window.addEventListener("scroll", e => {
//       if(this.pending == this.page() && scrollAt() > 90){
//         this.pending = this.page() + 1
//         console.log(this)
//         this.pushEvent("load-more", {})
//       }
//     })
//   },
//   updated(){ this.pending = this.page() }
// }

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

console.log(csrfToken);

// wip for theme swtiching
// const toggleSwitch = document.querySelector('.theme-switch input[type="checkbox"]');

// function switchTheme(e) {
//     if (e.target.checked) {
//         document.documentElement.setAttribute('data-theme', 'light');
//     }
//     else {
//         document.documentElement.setAttribute('data-theme', 'dark');
//     }
// }

// toggleSwitch.addEventListener('change', switchTheme, false);

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
