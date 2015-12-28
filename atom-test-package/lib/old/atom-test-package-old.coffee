{CompositeDisposable} = require 'atom'

module.exports = AtomTestPackage =
  subscriptions: null

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    console.log("hello")

    checkTop = @isAtTop

    @subscriptions.add atom.workspace.observeTextEditors (editor) ->

      subscription = editor.onDidChangeScrollTop (scrollTop) ->
        console.log("scrollTop = " + scrollTop)
        console.log("height = " + editor.getHeight())
        console.log("scrollHeight = " + editor.getScrollHeight())
        console.log("combined = " + (editor.getHeight() + scrollTop))

        if checkTop(editor, scrollTop)
          paneForItem = atom.workspace.paneForItem(editor)
          if paneForItem?
            paneForItem.activateNextItem()
            nextItem = paneForItem.getActiveItem()
            nextItem.scrollToTop()

      editor.onDidDestroy ->
          subscription.dispose()

  deactivate: ->
    @subscriptions.dispose()

  isAtTop: (editor, scrollTop) ->
    (editor.getHeight() + scrollTop) >= editor.getScrollHeight()
