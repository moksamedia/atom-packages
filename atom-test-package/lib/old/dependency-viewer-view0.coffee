{ScrollView} = require 'atom-space-pen-views'
{Disposable} = require 'atom'

module.exports =
class DependencyViewerView extends ScrollView

  model: null

  @content: ->
    @div()

  initialize: (model)->
    super
    @model = model
    @text('super long content that will scroll')
