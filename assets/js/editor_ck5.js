import InlineEditor from "@ckeditor/ckeditor5-build-inline";

// Or using the CommonJS version:
// const InlineEditor = require( '@ckeditor/ckeditor5-build-inline' );

let ExtensionHooks = {};

ExtensionHooks.MarkdownEditor = {
  mounted() {
    console.log("editor - ck5 loading");

    InlineEditor.create(document.querySelector(".editor_textarea"))
      .then((editor) => {
        window.editor = editor;
      })
      .catch((error) => {
        console.error("There was a problem initializing the editor.", error);
      });
  },
};

// add hooks to LiveView
Object.assign(liveSocket.hooks, ExtensionHooks);
