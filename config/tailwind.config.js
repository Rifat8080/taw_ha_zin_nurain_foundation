const flowbite = require("flowbite/plugin")

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*',
    './node_modules/flowbite/**/*.js'
  ],
  plugins: [
    flowbite.plugin
  ]
}
