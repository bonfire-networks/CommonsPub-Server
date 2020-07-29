import ClassicEditor from "@ckeditor/ckeditor5-editor-classic/src/classiceditor";

import Essentials from "@ckeditor/ckeditor5-essentials/src/essentials";
import Bold from "@ckeditor/ckeditor5-basic-styles/src/bold";
import Italic from "@ckeditor/ckeditor5-basic-styles/src/italic";
// import Underline from "@ckeditor/ckeditor5-basic-styles/src/underline";
import Code from "@ckeditor/ckeditor5-basic-styles/src/code";
// import Strikethrough from "@ckeditor/ckeditor5-basic-styles/src/strikethrough";
import Link from "@ckeditor/ckeditor5-link/src/link";
import Paragraph from "@ckeditor/ckeditor5-paragraph/src/paragraph";
import Heading from "@ckeditor/ckeditor5-heading/src/heading";

import Indent from "@ckeditor/ckeditor5-indent/src/indent";
import IndentBlock from "@ckeditor/ckeditor5-indent/src/indentblock";
import BulletedList from "@ckeditor/ckeditor5-list/src/list";
import NumberedList from "@ckeditor/ckeditor5-list/src/list";

import TodoList from "@ckeditor/ckeditor5-list/src/todolist";
import Mention from "@ckeditor/ckeditor5-mention/src/mention";

import Autoformat from "@ckeditor/ckeditor5-autoformat/src/autoformat";

import GFMDataProcessor from "@ckeditor/ckeditor5-markdown-gfm/src/gfmdataprocessor";
// Or using the CommonJS version:
// const InlineEditor = require( '@ckeditor/ckeditor5-build-inline' );

let ExtensionHooks = {};

// Simple plugin which loads the github-flavoured-markdown data processor.
function ck5Markdown(editor) {
  editor.data.processor = new GFMDataProcessor(editor.editing.view.document);
}

ExtensionHooks.MarkdownEditor = {
  mounted() {
    console.log("editor - ck5 loading!");

    ClassicEditor.create(document.querySelector(".editor_textarea"), {
      plugins: [
        ck5Markdown,

        Autoformat,

        Essentials,
        Paragraph,
        Bold,
        Italic,
        // Underline,
        // Strikethrough,
        Link,
        Heading,

        Indent,
        IndentBlock,
        BulletedList,
        NumberedList,

        Mention,
        MentionCustomization,

        // TodoList,
      ],
      toolbar: {
        items: [
          "bold",
          "italic",
          // "underline",
          // "strikethrough",
          "|",
          "code",
          "|",
          "link",
          "|",
          "heading",
          "|",
          "bulletedList",
          "numberedList",
          // "todoList",
          "|",
          "outdent",
          "indent",
          "|",
          "undo",
          "redo",
        ],
      },
      mention: {
        feeds: [
          {
            marker: "@",
            feed: getFeedItems,
            itemRenderer: mentionItemRenderer,
          },
        ],
      },
    })
      .then((editor) => {
        console.log("qui tutto bene");
        window.editor = editor;
      })
      .catch((error) => {
        console.log("nein");
        console.error("There was a problem initializing the editor.", error);
      });
  },
};

function getFeedItems(queryText) {
  if (queryText && queryText.length > 0) {
    return new Promise((resolve) => {
      fetch("/api/tag/autocomplete/ck5/@/" + queryText)
        .then((response) => response.json())
        .then((data) => resolve(data))
        .catch((error) => {
          console.error("There has been a problem with the tag search:", error);
        });
    });
  }
}

function MentionCustomization(editor) {
  // The upcast converter will convert <a class="mention" href="" data-user-id="">
  // elements to the model 'mention' attribute.
  editor.conversion.for("upcast").elementToAttribute({
    view: {
      name: "a",
      key: "data-mention",
      classes: "mention",
      attributes: {
        href: true,
        "data-user-id": true,
      },
    },
    model: {
      key: "mention",
      value: (viewItem) => {
        // The mention feature expects that the mention attribute value
        // in the model is a plain object with a set of additional attributes.
        // In order to create a proper object, use the toMentionAttribute helper method:
        const mentionAttribute = editor.plugins
          .get("Mention")
          .toMentionAttribute(viewItem, {
            // Add any other properties that you need.
            link: viewItem.getAttribute("href"),
            // userId: viewItem.getAttribute("data-user-id"),
          });

        return mentionAttribute;
      },
    },
    converterPriority: "high",
  });

  // Downcast the model 'mention' text attribute to a view <a> element.
  editor.conversion.for("downcast").attributeToElement({
    model: "mention",
    view: (modelAttributeValue, viewWriter) => {
      // Do not convert empty attributes (lack of value means no mention).
      if (!modelAttributeValue) {
        return;
      }

      return viewWriter.createAttributeElement(
        "a",
        {
          class: "mention",
          "data-mention": modelAttributeValue.id,
          // "data-user-id": modelAttributeValue.userId,
          href: modelAttributeValue.link,
        },
        {
          // Make mention attribute to be wrapped by other attribute elements.
          priority: 20,
          // Prevent merging mentions together.
          id: modelAttributeValue.uid,
        }
      );
    },
    converterPriority: "high",
  });
}

function mentionItemRenderer(item) {
  const itemElement = document.createElement("span");

  itemElement.classList.add("custom-item");
  // itemElement.id = `mention-list-item-id-${item.userId}`;
  itemElement.textContent = `${item.name} `;

  const usernameElement = document.createElement("span");

  usernameElement.classList.add("custom-item-username");
  usernameElement.textContent = item.id;

  itemElement.appendChild(usernameElement);

  return itemElement;
}

// add hooks to LiveView
Object.assign(liveSocket.hooks, ExtensionHooks);
