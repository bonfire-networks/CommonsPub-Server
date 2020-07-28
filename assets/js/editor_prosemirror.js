// import "../../lib/moodle_net_web/live/pages/my/create/write/editors/prosemirror.scss";
// import "../node_modules/prosemirror-view/style/prosemirror.css";

import { EditorView } from "prosemirror-view";
import { EditorState } from "prosemirror-state";
import {
  schema,
  defaultMarkdownParser,
  defaultMarkdownSerializer,
} from "prosemirror-markdown";
import { exampleSetup } from "prosemirror-example-setup";
// import { inputRules, InputRule } from "prosemirror-inputrules";

let ExtensionHooks = {};
var md_view = null;
var md_last_content = null;

ExtensionHooks.MarkdownEditor = {
  mounted() {
    console.log("editor - prosemirror loading");
    // console.log(this.el);

    const el_raw = this.el.querySelector(".editor_textarea");
    const el_md = this.el.querySelector(".editor_markdown");
    const el_visual_toggle = document.querySelector(".editor-style"); //FIXME: support several toggles

    class ProseMirrorView {
      constructor(target, content) {
        let view = new EditorView(target, {
          state: EditorState.create({
            doc: defaultMarkdownParser.parse(content),
            plugins: exampleSetup({ schema }),
          }),
          dispatchTransaction(tr) {
            view.updateState(view.state.apply(tr));
            //current state value:
            var cur_content = defaultMarkdownSerializer.serialize(
              view.state.doc
            );
            if (md_last_content != cur_content) {
              // console.log("edited: " + cur_content);
              el_raw.value = cur_content;
              md_last_content = cur_content;
            }
          },
        });
        this.view = view;
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

    function enable_markdown() {
      console.log("enable md with:");
      if (el_raw && el_md) {
        console.log(el_raw.value);
        el_raw.style.display = "none";
        // el_raw.style.visibility = "hidden";

        md_view = new ProseMirrorView(el_md, el_raw.value || "");
        md_view.focus();
      }
    }

    if (el_visual_toggle) {
      el_visual_toggle.addEventListener("change", (e) => {
        // console.log(e);
        if (!e.target.checked) {
          console.log("disable md with:");
          console.log(md_view.content);
          el_raw.value = md_view.content;
          md_view.destroy();
          el_raw.style.display = "block";
          // el_raw.style.visibility = "visible";
          el_raw.focus();
        } else {
          // visual
          enable_markdown();
        }
      });
      el_visual_toggle.checked = true;
    }

    // now enable markdown
    enable_markdown(); // with does checking not suffise?
  },
};

// add hooks to LiveView
Object.assign(liveSocket.hooks, ExtensionHooks);
