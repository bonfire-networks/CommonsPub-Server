const path = require('path')
const camelCase = require('lodash/camelCase')
const upperFirst = require('lodash/upperFirst')
const { styles, theme } = require('./styleguide.styles')
const { version } = require('./package.json')

const webpackConfig = require('./config/webpack.config.dev.js')

// these are components we don't need for generation of the style guide
// and may even cause generation to fail if included
const removePlugins = [
  'HtmlWebpackPlugin',
  'InterpolateHtmlPlugin',
]

webpackConfig.plugins = webpackConfig.plugins.filter(plugin => {
  return !removePlugins.includes(plugin.constructor.name)
})

webpackConfig.module.rules.push({
  test: /\.mjs$/,
  include: /node_modules/,
  type: 'javascript/auto',
});

module.exports = {
  title: `MoodleNet ${version}`,
  template: './styleguide.template.html',
  editorConfig: { theme: 'cobalt' },
  showUsage: true,
  styles,
  theme,

  components: 'src/components/**/*.tsx',
  ignore: [
    'src/components/chrome/{Body,Menu,Nav,Main}/*.tsx',
    'src/components/typography/LI/*.tsx',
    'src/components/elements/flag/*.tsx',
    'src/components/inputs/LanguageSelect/*.tsx',
  ],
  propsParser:
  require('react-docgen-typescript')
    .withCustomConfig('./tsconfig.json')
    .parse,
  styleguideComponents: {
    Wrapper: path.join(__dirname, 'src/styleguide/Wrapper.tsx')
  },
  webpackConfig
}
