import ClassicEditor from "@ckeditor/ckeditor5-editor-classic/src/classiceditor";

import Essentials from "@ckeditor/ckeditor5-essentials/src/essentials";
import Bold from "@ckeditor/ckeditor5-basic-styles/src/bold";
import Italic from "@ckeditor/ckeditor5-basic-styles/src/italic";
// ...

import GFMDataProcessor from "@ckeditor/ckeditor5-markdown-gfm/src/gfmdataprocessor";
// Or using the CommonJS version:
// const InlineEditor = require( '@ckeditor/ckeditor5-build-inline' );

let ExtensionHooks = {};

// Simple plugin which loads the data processor.
function ck5Markdown(editor) {
  editor.data.processor = new GFMDataProcessor(editor.editing.view.document);
}

ExtensionHooks.MarkdownEditor = {
  mounted() {
    console.log("editor - ck5 loading!");

    ClassicEditor.create(document.querySelector(".editor_textarea"), {
      plugins: [
        ck5Markdown,

        // Essentials,
        // Bold,
        // Italic,
        // ...
      ],
      // ...
    })
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
