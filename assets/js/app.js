// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";
// import "../node_modules/prosemirror-view/style/prosemirror.css";

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
      const prefix = "+"; // TODO: support other triggers
      if (this.el.dataset.target) {
        const f = document.getElementById(this.el.dataset.target);
        var ta = f.value.split(prefix);
        ta.pop();
        ta.push(this.el.dataset.tag + " "); // terminate with space
        f.value = ta.join(prefix);
        document.getElementById("autocomplete-dropdown").innerHTML = "";
      }
    });
  },
};

import { EditorView } from "prosemirror-view";
import { EditorState } from "prosemirror-state";
import {
  schema,
  defaultMarkdownParser,
  defaultMarkdownSerializer,
} from "prosemirror-markdown";
import { exampleSetup } from "prosemirror-example-setup";
import { inputRules, InputRule } from "prosemirror-inputrules";

Hooks.MarkdownEditor = {
  mounted() {
    console.log("MarkdownEditor mounted");

    class ProseMirrorView {
      constructor(target, content) {
        this.view = new EditorView(target, {
          state: EditorState.create({
            doc: defaultMarkdownParser.parse(content),
            plugins:
              // [
              exampleSetup({ schema }),
            //   inputRules({
            //     rules: [
            //       InputRule("t$", (state, match, start, end) => {
            //         console.log("tag! ");
            //       }),
            //     ],
            //   }),
            // ],
          }),
        });
      }

      get content() {
        return defaultMarkdownSerializer.serialize(this.view.state.doc);
      }
      focus() {
        this.view.focus();
      }
      destroy() {
        this.view.destroy();
      }
    }

    let el_md = document.getElementById("editor-markdown");
    let el_raw = document.getElementById("content");
    let md_view = null;

    function enable_markdown() {
      console.log("enable_md");
      console.log(el_raw.value);
      el_raw.style.display = "none";
      md_view = new ProseMirrorView(el_md, el_raw.value);
      md_view.focus();
    }

    document.querySelectorAll(".editor-controls input").forEach((button) => {
      button.addEventListener("change", () => {
        if (!button.checked) return;
        if (button.value == "raw") {
          el_raw.value = md_view.content;
          md_view.destroy();
          el_raw.style.display = "block";
          el_raw.focus();
        } else {
          // visual
          enable_markdown();
        }
      });
    });

    // now enable markdown
    document.getElementById("editor-style-visual").checked = true;
    enable_markdown(); // with does checking not suffise?
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

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
