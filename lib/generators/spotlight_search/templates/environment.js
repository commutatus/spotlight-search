const { environment } = require('@rails/webpacker')
const coffee = require('./loaders/coffee')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: require.resolve('jquery'),
    jQuery: require.resolve('jquery')
  })
)

const { add_paths_to_environment } = require(
  // `${environment.plugins.get('Environment').defaultValues["PWD"]}/config/environments/_add_gem_paths`
  `/tmp/_add_gem_paths`
)
add_paths_to_environment(environment)

environment.loaders.prepend('coffee', coffee)
module.exports = environment
