{allowUnsafeNewFunction} = require 'loophole'
Vue = require 'vue'

module.exports =
class DependencyViewerViewModel

  constructor:(@model, @element) ->
    @vue = allowUnsafeNewFunction =>
      new Vue
        el: @element
        data: @model
