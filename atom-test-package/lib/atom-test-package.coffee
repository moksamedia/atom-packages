{CompositeDisposable} = require 'atom'
url = require 'url'
{Lexer} = require './coffee-script/lexer'
DependencyViewerModel = require './dependency-viewer-model'
DependencyViewerView = require './dependency-viewer-element'
DependencyViewerViewModel = require './dependency-viewer-viewmodel'

module.exports = AtomTestPackage =

  coffeescriptPattern: /^.*\.coffee$/
  visible:false

  activate: (state) ->

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'testpackage:go': => @go()
    @lexer = new Lexer()

    atom.workspace.onDidStopChangingActivePaneItem (item) =>
      @model?.setActiveEditor(item)

  deactivate: ->
    @subscriptions.dispose()

  getTokens: (coffeeText) ->
    @lexer.tokenize(coffeeText)

  printTokens: (tokens) ->
    ((t) -> console.log(JSON.stringify(t))) token for token in tokens

  isCoffee: (fileName) ->
    fileName.match(@coffeescriptPattern)

  go: ->
    @toggle()

  toggle: ->
    if @isVisible()
      @detach()
    else
      @show()

  isVisible: ->
    @visible

  show: ->
    @visible = true
    @attach()

  attach: ->
    @model = new DependencyViewerModel()
    @model.setActiveEditor(atom.workspace.getActivePaneItem())
    @view = new DependencyViewerView()
    @view.initialize()
    @viewModel = new DependencyViewerViewModel @model.getData(), @view.getVueElement()
    @panel ?= atom.workspace.addRightPanel({item:@view})

  detach: ->
    @visible = false
    model = null
    @panel.destroy()
    @panel = null
