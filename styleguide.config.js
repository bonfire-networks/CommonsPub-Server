const path = require('path')

const webpackConfig = require('./config/webpack.config.dev.js')

// these are plugins we don't need for generation of the style guide
// and may even cause generation to fail if included
const removePlugins = [
	'HtmlWebpackPlugin',
	'InterpolateHtmlPlugin',
]

webpackConfig.plugins = webpackConfig.plugins.filter(plugin => {
	return !removePlugins.includes(plugin.constructor.name)
})

module.exports = {
	components: 'src/components/**/*.tsx',
  propsParser:
		require('react-docgen-typescript')
			.withCustomConfig('./tsconfig.json')
			.parse,
  styleguideComponents: {
		Wrapper: path.join(__dirname, 'src/styleguide/Wrapper.tsx')
	},
  template: {
    head: {
      links: [
        {
          rel: 'stylesheet',
					// this should be the same as the link element in `public/index.html`
          href: 'https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700'
        }
      ]
    }
  },
  theme: {
    fontFamily: {
      base: '"Open Sans", sans-serif'
    }
  },
	webpackConfig
}
