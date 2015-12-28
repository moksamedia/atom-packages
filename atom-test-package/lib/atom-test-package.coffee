{CompositeDisposable} = require 'atom'
url = require 'url'
{Lexer} = require './coffee-script/lexer'
DependencyViewerModel = require './dependency-viewer-model'
DependencyViewerView = require './dependency-viewer-element'
DependencyViewerViewModel = require './dependency-viewer-viewmodel'

module.exports = AtomTestPackage =

  coffeescriptPattern: /^.*\.coffee$/

  activate: (state) ->
    @model = new DependencyViewerModel

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'testpackage:go': => @go()
    @lexer = new Lexer()

    atom.workspace.onDidStopChangingActivePaneItem (item) =>
      @model.setActiveEditor(item)

    atom.views.addViewProvider DependencyViewerModel, (aModel) =>
      @view = new DependencyViewerView()
      @view.initialize()
      @viewModel = new DependencyViewerViewModel @model, @view.getVueElement()
      @view

  deactivate: ->
    @subscriptions.dispose()

  getTokens: (coffeeText) ->
    @lexer.tokenize(coffeeText)

  printTokens: (tokens) ->
    ((t) -> console.log(JSON.stringify(t))) token for token in tokens

  isCoffee: (fileName) ->
    fileName.match(@coffeescriptPattern)

  go: ->
    atom.workspace.addRightPanel({item: @model})
