{allowUnsafeNewFunction} = require 'loophole'
Vue = require 'vue'
Vue.config.debug = true

module.exports =
class DependencyViewerViewModel

  constructor:(data, element) ->
    console.log("-DATA = " + JSON.stringify(data))
    @vue = allowUnsafeNewFunction =>
      new Vue
        el: element
        data: data
