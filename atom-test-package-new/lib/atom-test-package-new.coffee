AtomTestPackageNewView = require './atom-test-package-new-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomTestPackageNew =
  atomTestPackageNewView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomTestPackageNewView = new AtomTestPackageNewView(state.atomTestPackageNewViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomTestPackageNewView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-test-package-new:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomTestPackageNewView.destroy()

  serialize: ->
    atomTestPackageNewViewState: @atomTestPackageNewView.serialize()

  toggle: ->
    console.log 'AtomTestPackageNew was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
