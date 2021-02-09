const webpack = require('webpack');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const path = require('path');

const mode = process.env.NODE_ENV || 'development';
const prod = mode === 'production';
const dev = !prod;
const useCache = process.env.CACHE || 'true';

const magicImporter = require('node-sass-magic-importer');
const sveltePreprocess = require('svelte-preprocess');
const CopyPlugin = require('copy-webpack-plugin');
const onwarn = (warning, onwarn) => warning.code === 'css-unused-selector' || onwarn(warning);

const SpeedMeasurePlugin = require("speed-measure-webpack-plugin");

const smp = new SpeedMeasurePlugin();

const alias = {
      svelte: path.resolve('node_modules', 'svelte'),
      'src': path.resolve(__dirname, 'src'),
      'd': path.resolve(__dirname, 'src/lib/debug'),
      // 'bignumber.js$': 'bignumber.js/bignumber.js',
    };
const  HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = smp.wrap({
  entry: {
    bundle: ['./src/index.js'],
  },
  resolve: {
    alias: alias,
    extensions: ['.mjs', '.js', '.ts', '.svelte', '.css', '.scss'],
    mainFields: ['svelte', 'browser', 'module', 'main'],
  },
  output: {
    publicPath: '',
    path: path.resolve(__dirname, '../www'),
    filename: '[name][hash].js',
    chunkFilename: '[name].[id][hash].js'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: useCache === true || useCache ==='true' ? [
          {
            loader: 'cache-loader',
          },
          {
            loader: 'babel-loader',
          }
        ]:[
          {
            loader: 'babel-loader',
          }
        ]
      },
      {
        test: /\.svelte$/,
        use: prod && useCache === 'true' ? [
          {
            loader: 'cache-loader'
          },
          {
          loader: 'svelte-loader',
          options: {
            dev,
            onwarn,
            preprocess: sveltePreprocess({
              scss: {
                importer: [magicImporter()],
              },
              typescript: {
                // skips type checking
                transpileOnly: prod ? true : false,
              },
            }),
            compilerOptions: {
              dev: !prod
            },
            emitCss: prod,
            hotReload: !prod
          },
        }] : [
          {
            loader: 'svelte-loader',
            options: {
              dev,
              onwarn: onwarn,
              preprocess: sveltePreprocess({
                scss: {
                  importer: [magicImporter()],
                },
                typescript: {
                  // skips type checking
                  transpileOnly: prod ? true : false,
                },
              }),
              compilerOptions: {
                dev: !prod
              },
              emitCss: prod,
              hotReload: !prod
            },
          }
        ],
      },
      {
        test: /\.(md|svg|ico|jpg|jpeg|png|gif|eot|otf|webp|ttf|woff|woff2|cur|ani|pdf|ogg)(\?.*)?$/,
        loader: 'file-loader',
      },
      {
        test: /\.(scss|sass|css)$/,
        use: prod && useCache === 'true' ? [
          {
            loader: 'cache-loader'
          },
          prod ? MiniCssExtractPlugin.loader : 'style-loader',
          { loader: 'css-loader', options: { sourceMap: true } },
          {
            loader: 'sass-loader',
            options: {
              sassOptions: {
                importer: magicImporter(),
              },
            },
          },
        ] : [
          prod ? MiniCssExtractPlugin.loader : 'style-loader',
          { loader: 'css-loader', options: { sourceMap: true } },
          {
            loader: 'sass-loader',
            options: {
              sassOptions: {
                importer: magicImporter(),
              },
            },
          },
        ],
      },
    ],
  },
  mode,
  plugins: prod ? [
    new CleanWebpackPlugin(),
    new MiniCssExtractPlugin({
      filename: '[name][contenthash].css',
    }),
    new webpack.ProvidePlugin({
      j: 'jquery',
      jQuery: 'jquery',
      'd': 'd'
    }),

    new HtmlWebpackPlugin({
      hash: true,
      template: './public/template.html',
      filename: './index.html'
    }),
    new CopyPlugin({
      patterns: [
                { from: './public/favicon.png', to: './favicon.png' },
      ] 
    }),
  ] : [
    new MiniCssExtractPlugin({
      filename: '[name][contenthash].css',
    }),
    new webpack.ProvidePlugin({
      j: 'jquery',
      jQuery: 'jquery',
      'd': 'd'
    }),

    new HtmlWebpackPlugin({
      hash: true,
      template: './public/template.html',
      filename: './index.html'
    }),
  ],
  devtool: prod ? false : 'source-map',
  devServer: {
    contentBase: 'public',
    host: '0.0.0.0',
    port: 80,
    hot: true,
    overlay: true,
    historyApiFallback: true,
    disableHostCheck: true,
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
});

