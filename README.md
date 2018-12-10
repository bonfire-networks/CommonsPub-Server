# MoodleNet Web Client

This React project was bootstrapped with [Create React App](https://github.com/facebookincubator/create-react-app).
It has changed dramatically since its initial creation so the CRA documentation is no longer relevant and has been
removed from the README, however this notice is left here just in case it can be informative and for posterity.

## Glossary

- [Structure](#structure)
    - [High level folder structure](#high-level-folder-structure)
    - [Application source folder structure](#application-source-folder-structure)
- [Scripts](#scripts)
    - [`npm start`](#npm-start)
    - [`npm add-locale`](#npm-add-locale)
    - [`npm extract`](#npm-extract)
    - [`npm compile`](#npm-compile)
    - [`npm build`](#npm-build)
- [Libraries](#libraries)
- [Theme](#theme)
    - [Theme structure](#theme-structure)
    - [Themed components](#themed-components)
    - [Adding a theme](#adding-a-theme)
    - [Using a theme](#using-a-theme)
    - [Themeing Zendesk Garden](#themeing-zendesk-garden)
    - [Grid system](#grid-system)
- [Localisation](#localisation)
    - [Set up](#set-up)
    - [Usage](#usage)
    - [Simple language strings](#simple-language-strings)
    - [Language strings as reference](#language-strings-as-reference)
    - [Plural language strings](#plural-language-strings)
    - [Interpolated language strings](#interpolated-language-strings)
    - [Updating language files](#updating-language-files)
- [Dependencies](#dependencies)

## Structure

### High level folder structure:

| Folder | Description |
|------|---|
| `/build` | the output directory containing static assets & application files |
| `/config` | contains all configuration for the build tooling, i.e. webpack |
| `/public` | files that will be copied into the `build` folder |
| `/scripts` | "run" files should be invoked via their respective `npm run` command |
| `/src` | the application source | 

### Application source folder structure:

| Folder | Description |
|------|---|
| `/src/apollo` | all (react-)apollo boilerplate, type definitions, and resolvers |
| `/src/components` | all react components are stored here which are reusable, organised by type |
| `/src/containers` | high-level react container components which handle routing, state, and localisation set-up |
| `/src/graphql` | contains queries & (local state) mutation grapql query definitions |
| `/src/locales` | locale folders define the available locales (managed by linguijs) and each contains its locale's language data |
| `/src/pages` | user-facing application pages which are used in routing in the App container |
| `/src/static` | static assets such as images that are used within the application code (for example, images can be `require`'d with webpack) |
| `/src/styleguide` | contains files pertaining to react-styleguidist, such as a Wrapper component used to display all components in the styleguide within the Zen Garden theme provider |
| `/src/styles` | css files go in here, for styles that are not component-specific (i.e. not generated with `styled-component`) or for which a library relies on (e.g. flag icons) |
| `/src/themes` | the application Zen Garden theme set configuration and own theme files, with the `default.theme.ts` being the MoodleNet theme |
| `/src/types` | application typescript types, enums, & interfaces |
| `/src/util` | application utility functions |

## Scripts

In the project directory, you can run:

### `npm start`

Runs the app in the development mode.
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.
You will also see any lint errors in the console.

### `npm add-locale`

Adds a locale for localisation, with [lingui library](https://lingui.js.org/ref/react.html).<br>

### `npm extract`

Extracts new/updated strings from the codebase into JSON files for localisation (they need to be encapsulated with [lingui library](https://lingui.js.org/ref/react.html)'s <Trans>).<br>

### `npm compile`

Compiles localisation files for production.<br>

### `npm build`

Builds the app for production to the `build` folder.<br>
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.<br>

## Libraries

This section mentions notable libraries and tools used within the application and links to their documentation.

- TypeScript (https://www.typescriptlang.org)
- webpack (https://webpack.js.org) 
- 

## Theme

The application uses the [Zendesk Garden](https://zendeskgarden.github.io) toolkit for its React and CSS component suites
and also as it comes the "themeing" built-in. This means we apply our own "MoodlNet style" to the components in the Zendesk
Garden toolkit.

This section details how themeing is implemented in the application, how to develop new components that are themed, how
to edit the default theme, and how to introduce new themes.

### Theme structure

Files that are used in themeing are described in the table below.

| File | Description |
|---|---|
| `themes/create.ts` | a utility function that generates a Zendesk Garden-specific theme object definition from a theme variable hash |
| `themes/default.theme.ts` | the default MoodleNet theme |
| `themes/index.ts` | exports all available themes within the application |
| `themes/styled.ts` | defines and gathers all theme and `styled-components` interfaces and utilities into one file |

### Themed components

Zendesk Garden comes with lots of built-in components, visual components are defined in CSS (i.e. created with class names)
and some of these are also available as React components. Some React components are not available in CSS and vice-versa.

The components can be viewed here:

- [Zendesk CSS components](zendeskgarden.github.io/css-components/)
- [React components](https://zendeskgarden.github.io/react-components/) 

In this application any Zendesk component that is used should be wrapped within a local component. For example, see
the Pagination component (`src/components/Pagination/Pagination.tsx`), which looks like this:

```typescript jsx
import * as React from 'react';
import { Pagination } from '@zendeskgarden/react-pagination';

export default function({ ...props }) {
  return <Pagination {...props} />;
}
```

The reasons for this are 1) it is easy to see within the component directory hierarcy which components are already
available and have been styled and 2) we can build extra MoodleNet-specific functionality into the components this way.

### Adding a theme

It is relatively easy to create a new theme:

- copy the `themes/default.theme.ts` file to a new file, e.g. `dark.theme.ts`
- amend the theme variables in the new theme file to whatever you like
- add an export in `themes/index.ts` for the new theme file, making sure to rename the `theme` export to something unique:

    ```js
    // for example
    export { theme as dark } from './dark.theme';
    ```

- that's it!

### Using a theme

The application does not (yet) have a way for the user to choose a theme. The theme in use is configured in code. 

To use a different theme:

- open the App container (`src/containers/App/App.tsx`)
- import the them you want to use (or amend the existing import for the `moodlent` theme)
- update the `ThemeProvider` JSX element `theme` prop to use the new theme definition

### Themeing Zendesk Garden

The Zendesk Garden suite is themed using the `ThemeProvider` component, which takes as a prop
a theme definition. This theme definition contains the theme variables (as in a theme file created above
in [Adding a theme](#adding-a-theme)) and also component-specific styles, which are defined using
Zendesk Garden's own component naming scheme.

For example, to theme the Pagination Zendesk Garden component, we add a key in our theme definition
object which is the component's canonical "name" in the theme system. This isn't actually referenced anywhere
in the Zendesk Garden documentation so the easiest way to find it out is by looking at the source code of the 
component.

For example, for the Pagination Page sub-component we can see the canonical component name in
`node_modules/@zendeskgarden/react-pagination/dist/index.js`:

```
var COMPONENT_ID = 'pagination.page';
```

Now we can style the component in our `createTheme` function in `themes/create.tsx` by adding a key
in the definition like so:

```js
  {
    //...
    'pagination.page': `
        &&[class*=is-current] {
            background-color: ${theme.colour.primary};
            color: white;
        }
    `,
    //...
  } 
```

The styles can be written using SASS syntax. It is necessary to use a double ampersand to target the 
component element, as (presumably) this style will be merged into Zendesk Garden's own declaration for the element.

### Grid system

The application makes use of the Zendesk Garden [Grid components](https://garden.zendesk.com/react-components/grid/).
This is a typical responsive column & row grid framework.

> The Grid component is an implementation over the [Bootstrap v4 Flexbox Grid](http://getbootstrap.com/docs/4.0/layout/overview/). 
> Their documentation is a great resource to explore all of the unique customizations available within this package. 

Given that grid columns adapt to the dimensions of the user agent viewport, when possible components should always
be built with the capability to reduce their size to fit within their container, and should not therefore 
use fixed widths.

## Localisation

[LinguiJS](https://lingui.js.org/) is the localisation library used for i18n.

### Set up

- LinguiJS is configured in the `.linguirc` file in the root of the application.

- It comes with a provider component that sets up i18n within the application and makes components
within the app able to consume the language strings of the user's chosen locale. The provider
is configured in the App container (`src/containers/App/App.tsx`).

- The app uses React 16 Context to manage the chosen locale and maintain a state around this.
The context (state) is also set up and handled within the aforementioned App container.

- Any component can "consume" the locale context by using the `LocaleContext` exported from the App 
container. This allows any component to access the API for changing the active locale. For example, 
the LanguageSelect component (`/src/components/inputs/LanguageSelect/LanguageSelect.tsx`) is wrapped
in the `LocaleContext.Consumer` component, giving it the `setLocale` function:

    ```jsx
      <LocaleContext.Consumer>
        {({ setLocale }) => (
          //...
        )})
      </LocaleContext.Consumer>
    ```

### Usage

Wherever you write visible text, i.e. anything user-facing, the copy should be written using the LinguiJS
components. The text used within the LinguiJS components can then be extracted using the CLI operations
provided by the library, which are detailed in the [Scripts](#scripts) section of this document.

Examples of using the LinguiJS library are given below.

#### Simple language strings

- First import the [`Trans` component](https://lingui.js.org/ref/react.html#trans):

    ```js
    import { Trans } from '@lingui/macro';
    ````
    
- _Note:_ the `Trans` component is imported from the `macro` package, not the `react` package! 

- Then consume the `Trans` component wherever text is used, like so:

    ```jsx
    <Trans>Sign in using your social media account</Trans>
    ```

#### Language strings as reference

- Import the [`i18nMark` function](https://lingui.js.org/ref/react.html#i18nmark).

    ```js
    import { i18nMark } from '@lingui/react';
    ```

- Define the language string however you like. It is usually the case that a file will contain more than one 
language string accessed via reference, in this case organise the strings within an object with properties
that describe their purpose. For example, from the Login page:

    ```js
    const tt = {
      //...
      validation: {
        email: i18nMark('The email field cannot be empty'),
        //...
      }
    }
    ````
    
- _Note:_ the `validation.email` string is wrapped in a call to `i18nMark`. As the string is not passed to (as props
or directly as children) to the `Trans` component it will not be picked up automatically by the LinguiJS extract
script. In order to "mark" the string as a language string to be included in the compiled language files we must
wrap it in a call to `i18nMark`.  

- Then consume the strings. Again, for example, from the Login page:
    
    ```jsx
    validation.push({
      field: ValidationField.email,
      type: ValidationType.error,
      message: tt.validation.email // <- notice the string reference here
    } as ValidationObject);
    ```
    
#### Plural language strings

LinguiJS has a `Plural` component, which is like the `Trans` component but used where the 
language contains pluralization.

> <Plural> component handles pluralization of words or phrases. 
> Selected plural form depends on active language and value props.

The LinguiJS documentation is very comprehensive and should be referred to for usage of the `Plural` component:

https://lingui.js.org/ref/react.html#plural

#### Interpolated language string

It is very common to interpolate values into language strings. This can be done using the `Trans` and `Plural` 
components, where the interpolated string names are denoted with curly braces (but still within the actual string) 
and the component is given a key/value hash via a `values` prop, where a key of the hash is the name of a string
to be interpolated. For example, from the Login page:

```jsx
<Trans
  id="You don't need an account to browse {site_name}."
  values={{ site_name: 'MoodleNet' }}
/>
```

It is possible then to have `site_name` or any other interpolated string value produced dynamically and inserted
during runtime. If interpolated values also require localisation then you would use a language string hash,
as above in [Language strings as reference](#language-strings-as-reference), making sure to use the `i18nMark`
function to mark them for extraction by the LinguiJS CLI.     

### Updating language files

Whenever updates are made to any language within the application you must run the LinguiJS `extract` script.
This will pull out all the language strings and add or update them in the specific locale messages files, which
live in `locales`.

All changes to the language within the application, including changes to the files within `locales`, should
be committed alongside other changes.    

## Dependencies

| Development Only | Package | Description |
|---|------|---|
| | `@absinthe/*` | the JS Absinthe toolkit used to interface with the Elixir Phoenix backend with GraphQL |
| X | `@babel/*` | compiles down ESNext syntax and functionality & includes runtime polyfills |
| | `@fortawesome/*` | a collection of react components and pre-packaged FontAwesome icon SVGs |
| | `@jumpn/utils-graphql` | a collection of utilities used to interrogate GraphQL links, such as is it a subscription, which determines what channel to communicate on (WebSocket if yes, HTTP if no) |
| | `@lingui/*` | lib for localisation of react applications, includes scripts for parsing the app code and pulling out language into locale files (which lives in `/locales/`), and react components such as localisation provider which sets up the react tree to get the correct language data depending on chosen locale | 
| | `@types/*` | the `@types` package namespace contains type definitions for some of packages we use, as TypeScript is opt-in an they are not included by default in some packages |
| | `@zendeskgarden/*` | the themeing library which comes with a set of React components and an interface and provider which is used to apply a custom theme |
| | `apollo-cache-inmemory` | standalone cache for apollo, it caches responses from the graphql backend |
| | `apollo-client` | a client for graphql |
| | `apollo-link-context` | allows setting the _context_ of apollo operations, used for example to set the Auth Bearer token in HTTP request headers |
| | `apollo-link-http` | allows the application to make graphql requests over HTTP |
| | `apollo-link-logger` | logs apollo operations as they happen, used in development for debugging apollo queries |
| | `apollo-link-retry` | allows apollo to automatically retry failed requests to the graphql backend |
| | `apollo-link-state` | like Redux but is queryable through graphql queries |
|X| `autoprefixer` | used to automatically apply vendor prefixes to styles output by webpack (via postcss) |
|X| `awesome-typescript-loader` | a webpack loader that compiles TypeScript files |
|X| `babel-core` | this is necessary even though we have `@babel/core` because some older libs depend on it (it is actually just the "bridge" which is installed) |
|X| `babel-plugin-async-import` | allows Babel to compile the async import syntax (`import()`) |
|X| `babel-plugin-macros` | allows us to use Babel macros, such as the one included with `linguijs` that pulls out language data to create the locales
|X| `case-sensitive-paths-webpack-plugin` | see `webpack.config.dev.js` |
|X| `chalk` | used to create colour in terminal logs using ascii escape codes |
|X| `cross-env` | allows us to apply environment variables in npm scripts that run across all platforms |
|X| `css-loader` | allows webpack to process CSS files |
| | `dotenv` | loads and processes `.env` files and applies contents to the environment (`process.env`) |
| | `dotenv-expand`  | allows interpolation of environment variables within the `.env` files themselves |
|X| `eslint` | used for linting application code |
|X| `eslint-config-react-app` | an ESLint config that CRA applications come bundles with |
|X| `eslint-loader` | allows webpack to run application files through ESLint |
|X| `file-loader` | allows webpack to copy files into the build directory |
| | `flag-icon-css` | used to generate flag icons |
|X| `fs-extra` | a better FS lib that comes with extra filesystem operations and is promisied |
| | `graphql` | the JS implementation of graphql, used by other graphql libs |
| | `graphql-tag` | a template literal tag that processes graphql query strings into their object representations |
|X| `html-webpack-plugin` | used in webpack to produce an `index.html` file, that includes script and style tags for all application stuff that is generated via webpack |
|X| `husky` | used by `lint-staged` to configure git hooks |
|X| `interpolate-html-plugin` | see `webpack.config.dev.js` |
|X| `lint-staged` | used to lint staged code before it is committed |
|X| `mini-css-extract-plugin` | pulls out CSS styles from application bundles into their own stylesheet files |
| | `object-assign` | `Object.assign` polyfill for older browsers (<=IE8) |
| | `phoenix` | JavaScript toolkit for interfacing with an Elixir Phoenix backend |
|X| `postcss-flexbugs-fixes` | fixes flexbox issues to make flexbox use cross-browser compatible |
|X| `postcss-loader` | allows webpack to make use of the postcss toolkit and plugin ecosystem |
|X| `prettier` | code formatter that automatically fixes linting problems and keeps the code looking according to a default code style |
| | `promise` | simple implementation of promises |
|X| `raf` | requestAnimationFrame polyfill for node and the browser |
| | `react` | used to build the user-interface of the application |
| | `react-apollo` | react components for connecting apollo and react, e.g. a provider that gives all components a context with which to make request to graphql backend |
| | `react-click-outside` | HOC used for catching clicks outside of a component, for example in order to close a menu when the user clicks off the menu |
|X| `react-dev-utils` | webpack utilities used by CRA |
|X| `react-docgen-typescript` | used by `react-styleguidist` to generate propType docs for react components from TypeScript prop definitions |
| | `react-dom` | react lib to render react trees into the browser's DOM |
| | `react-loadable` | makes loading components async and code-splitting easy in react-land |
| | `react-router-dom` | react router DOM-specific renderer |
|X| `react-styleguidist` | used to produce and display a styleguide for the application components |
| | `recompose` | utilities for react, such as HOC compose function to make multiple HOCs more readable |
|X| `style-loader` | webpack loader used in development to insert CSS as style tags |
| | `styled-components` | used to write CSS-in-JS |
|X| `sw-precache-webpack-plugin` | produces a service worker for the application via webpack that caches application files and makes the web app load offline |
|X| `terser-webpack-plugin` | minifier for webpack |
| | `time-ago` | produces readable strings for how long ago something happened from a timestamp, e.g. "5 minutes ago" |
| | `tslib` | TypeScript runtime |
| | `typescript` | TypeScript |
|X| `url-loader` | allows webpack to inline files (e.g. images) into base64 strings if they are below a certain byte limit |
|X| `webpack` | application build tool, bundles the application into compiled and servable files |
|X| `webpack-dev-server` | used to create a development server that reacts to changes in app files and serves them on-the-fly |
|X| `webpack-manifest-plugin` | see `webpack.config.dev.js` |
| | `whatwg-fetch` | `window.fetch` polyfill |
