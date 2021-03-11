const { resolve, onwarn } = require('../webpack.config');
const merge = require('webpack-merge');
const { CheckerPlugin } = require('awesome-typescript-loader');
const path = require('path');
const createCompiler = require('@storybook/addon-docs/mdx-compiler-plugin');
const magicImporter = require('node-sass-magic-importer');
const sveltePreprocess = require('svelte-preprocess');

module.exports = ({ config, mode }) => {
  // console.dir(config, { depth: null });
  let mergedConfig = merge.smart(config, {
    module: {
      rules: [
        {
          test: /\.(svelte|html)$/,
          loader: 'svelte-loader-hot',
          options: {
            onwarn: onwarn,
            preprocess: sveltePreprocess({
              scss: {
                importer: [magicImporter()],
              },
              typescript: {
                // skips type checking
                transpileOnly: false,
              },
            }),
            hotReload: true,
            hotOptions: {
              // whether to preserve local state (i.e. any `let` variable) or
              // only public props (i.e. `export let ...`)
              noPreserveState: false,
              // optimistic will try to recover from runtime errors happening
              // during component init. This goes funky when your components are
              // not pure enough.
              optimistic: true,
              noReload: false,
              // noPreserveStateKey: '__'
              // See docs of svelte-loader-hot for all available options:
              //
              // https://github.com/rixo/svelte-loader-hot#usage
            },
          }
        },
        {
          test: /\.stories\.tsx?$/,
          loaders: [
            {
              loader: require.resolve('@storybook/source-loader'),
              options: { parser: 'typescript' }
            }
          ],
          enforce: 'pre',
          include: [path.resolve(__dirname, '../src')]
        },
        {
          // 2a. Load `.stories.mdx` / `.story.mdx` files as CSF and generate
          //     the docs page from the markdown
          test: /\.(stories|story)\.mdx$/,
          use: [
            {
              loader: 'babel-loader',
              // may or may not need this line depending on your app's setup
              options: {
                plugins: ['@babel/plugin-transform-react-jsx']
              }
            },
            {
              loader: '@mdx-js/loader',
              options: {
                compilers: [createCompiler({})]
              }
            }
          ]
        },
        {
          test: /\.(stories|story)\.[tj]sx?$/,
          loader: require.resolve('@storybook/source-loader'),
          exclude: [/node_modules/],
          enforce: 'pre'
        }
      ]
    }
  });
  mergedConfig.resolve.alias = { ...mergedConfig.resolve.alias, ...resolve.alias };
  mergedConfig.plugins.push(new CheckerPlugin());
  return mergedConfig;
};
