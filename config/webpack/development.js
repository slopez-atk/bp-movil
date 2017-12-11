const environment = require('./environment');
// config/webpack/development.js
const merge = require('webpack-merge');
const customConfig = require('./custom');

module.exports = merge(environment.toWebpackConfig(), customConfig);


