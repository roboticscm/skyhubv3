const webpack = require('webpack');
const mode = process.env.NODE_ENV || 'development';
const cache = process.env.CACHE || true;


const prod = mode === 'production';
const dev = !prod;
const path = require('path');
const magicImporter = require('node-sass-magic-importer');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');
const onwarn = (warning, onwarn) => warning.code === 'css-unused-selector' || warning.code === 'a11y-no-onchange'  || onwarn(warning);

const alias = {
  svelte: path.resolve('node_modules', 'svelte'),
  'src': path.resolve(__dirname, 'src'),
  'd': path.resolve(__dirname, 'src/lib/js/debug'),
  // 'bignumber.js$': 'bignumber.js/bignumber.js',
};

const HtmlWebpackPlugin = require('html-webpack-plugin');
const SpeedMeasurePlugin = require("speed-measure-webpack-plugin");
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const smp = new SpeedMeasurePlugin();
module.exports = /*smp.wrap(*/{
  resolve: {
    alias: alias,
    extensions: ['.mjs', '.js', '.svelte', '.css', '.scss'],
    mainFields: ['svelte', 'browser', 'module', 'main'],
  },
  output: {
    path: path.resolve(__dirname, '../../../../www'),
    filename: '[name][hash].js',
    chunkFilename: '[name].[id][hash].js'
  },

  module: {

    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: cache === true || cache ==='true' ? [
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
        test: /\.(htm|svelte)$/,
        exclude: /node_modules/,
        use: cache === true || cache ==='true' ? [
          {
            loader: 'cache-loader',
          },
          {
            loader: 'svelte-loader-hot',
            options: {
              dev,
              onwarn,
              hotReload: true,
              hotOptions: {

              },
            }
          }
        ] : [
          {
            loader: 'svelte-loader-hot',
            options: {
              dev,
              hotReload: true,
              hotOptions: {

              },
            }
          }
        ]
      },
      {
        test: /\.(md|svg|ico|jpg|jpeg|png|gif|eot|otf|webp|ttf|woff|woff2|cur|ani|pdf|ogg)(\?.*)?$/,
        loader: 'file-loader',
      },
      {
        test: /\.(scss|sass|css)$/,
        use: cache === true || cache ==='true' ? [
          {
            loader: 'cache-loader',
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
          }
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
          }
        ]
      }
    ],
  },
  mode,
  plugins: cache === true || cache ==='true' ? [
    new MiniCssExtractPlugin({
      filename: '[name][contenthash].css',
    }),


    new HtmlWebpackPlugin({

      template: './public/template.html',
      filename: './index.html',
    }),
    new webpack.HotModuleReplacementPlugin(),
    new webpack.ProvidePlugin({
      j: 'jquery',
      jQuery: 'jquery',
      'd': 'd'
    }),
    new CopyPlugin({
      patterns: [
        { from: './public/favicon.png', to: './favicon.png' },
      ]
    }),
  ] : [
    new CleanWebpackPlugin(),
    new MiniCssExtractPlugin({
      filename: '[name][contenthash].css',
    }),
    new CopyPlugin({
      patterns: [
        { from: './public/favicon.png', to: './favicon.png' },
      ]
    }),

    new HtmlWebpackPlugin({

      template: './public/template.html',
      filename: './index.html',
    }),
    new webpack.HotModuleReplacementPlugin(),
    new webpack.ProvidePlugin({
      j: 'jquery',
      jQuery: 'jquery',
      'd': 'd'
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
}/*)*/;
