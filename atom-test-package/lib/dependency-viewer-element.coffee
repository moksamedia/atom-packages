{Disposable} = require 'atom'
fs = require 'fs'
path = require 'path'

class DependencyViewerElement extends HTMLElement

  scrollView: null
  containerDiv: null

  createdCallback: ->
    console.log("createdCallback")

  attachedCallback: ->
    console.log("attachedCallback")

  detachedCallback: ->
    console.log("detachedCallback")

  initialize: ->
    console.log("initialize")
    @rootElement = this

    @scrollView = document.createElement('div')
    @scrollView.classList.add('dependency-viewer-scroll-view')
    @rootElement.appendChild @scrollView

    @containerDiv = document.createElement('div')
    @containerDiv.classList.add('dependency-viewer-container')
    @containerDiv.innerHTML = fs.readFileSync(path.join(__dirname, 'dependency-viewer-content-template.html'))

    @scrollView.appendChild @containerDiv

  getVueElement: ->
    @containerDiv

module.exports = DependencyViewerView = document.registerElement 'dependency-viewer', prototype: DependencyViewerElement.prototype
