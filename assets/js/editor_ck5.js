import ClassicEditor from "@ckeditor/ckeditor5-editor-classic/src/classiceditor";

import Essentials from '@ckeditor/ckeditor5-essentials/src/essentials';
import Bold from '@ckeditor/ckeditor5-basic-styles/src/bold';
import Italic from '@ckeditor/ckeditor5-basic-styles/src/italic';
import Underline from '@ckeditor/ckeditor5-basic-styles/src/underline';
import Strikethrough from '@ckeditor/ckeditor5-basic-styles/src/strikethrough';
import Mention from '@ckeditor/ckeditor5-mention/src/mention';
import Link from '@ckeditor/ckeditor5-link/src/link';
import Paragraph from '@ckeditor/ckeditor5-paragraph/src/paragraph';
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
        Essentials, 
        Paragraph, 
        Mention, 
        Bold, 
        Italic, 
        Underline, 
        Strikethrough, 
        Link 
      ],
      toolbar: {
        items: [
            'bold', 'italic', 'underline', 'strikethrough', '|', 'link', '|', 'undo', 'redo'
        ]
    },
    mention: {
      feeds: [
          {
              marker: '@',
              feed: [
                  { id: '@cflores', avatar: 'm_1', name: 'Charles Flores' },
                  { id: '@gjackson', avatar: 'm_2', name: 'Gerald Jackson' },
                  { id: '@wreed', avatar: 'm_3', name: 'Wayne Reed' },
                  { id: '@lgarcia', avatar: 'm_4', name: 'Louis Garcia' },
                  { id: '@rwilson', avatar: 'm_5', name: 'Roy Wilson' },
                  { id: '@mnelson', avatar: 'm_6', name: 'Matthew Nelson' },
                  { id: '@rwilliams', avatar: 'm_7', name: 'Randy Williams' },
                  { id: '@ajohnson', avatar: 'm_8', name: 'Albert Johnson' },
                  { id: '@sroberts', avatar: 'm_9', name: 'Steve Roberts' },
                  { id: '@kevans', avatar: 'm_10', name: 'Kevin Evans' },
                  { id: '@mwilson', avatar: 'w_1', name: 'Mildred Wilson' },
                  { id: '@mnelson', avatar: 'w_2', name: 'Melissa Nelson' },
                  { id: '@kallen', avatar: 'w_3', name: 'Kathleen Allen' },
                  { id: '@myoung', avatar: 'w_4', name: 'Mary Young' },
                  { id: '@arogers', avatar: 'w_5', name: 'Ashley Rogers' },
                  { id: '@dgriffin', avatar: 'w_6', name: 'Debra Griffin' },
                  { id: '@dwilliams', avatar: 'w_7', name: 'Denise Williams' },
                  { id: '@ajames', avatar: 'w_8', name: 'Amy James' },
                  { id: '@randerson', avatar: 'w_9', name: 'Ruby Anderson' },
                  { id: '@wlee', avatar: 'w_10', name: 'Wanda Lee' }
              ],
          },
          {
              marker: '#',
              feed: [
                  '#american', '#asian', '#baking', '#breakfast', '#cake', '#caribbean',
                  '#chinese', '#chocolate', '#cooking', '#dairy', '#delicious', '#delish',
                  '#dessert', '#desserts', '#dinner', '#eat', '#eating', '#eggs', '#fish',
                  '#food', '#foodgasm', '#foodie', '#foodporn', '#foods', '#french', '#fresh',
                  '#fusion', '#glutenfree', '#greek', '#grilling', '#halal', '#homemade',
                  '#hot', '#hungry', '#icecream', '#indian', '#italian', '#japanese', '#keto',
                  '#korean', '#lactosefree', '#lunch', '#meat', '#mediterranean', '#mexican',
                  '#moroccan', '#nom', '#nomnom', '#paleo', '#poultry', '#snack', '#spanish',
                  '#sugarfree', '#sweet', '#sweettooth', '#tasty', '#thai', '#vegan',
                  '#vegetarian', '#vietnamese', '#yum', '#yummy'
              ]
          }
      ]
    }
    })
      .then((editor) => {
        console.log("qui tutto bene")
        window.editor = editor;
      })
      .catch((error) => {
        console.log("nein")
        console.error("There was a problem initializing the editor.", error);
      });
  },
};

// add hooks to LiveView
Object.assign(liveSocket.hooks, ExtensionHooks);
