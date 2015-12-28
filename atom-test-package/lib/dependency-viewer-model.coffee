{CompositeDisposable} = require 'atom'
{allowUnsafeNewFunction, allowUnsafeEval} = require 'loophole'
Madge = allowUnsafeNewFunction -> require 'madge'
path = require 'path'

module.exports =
class DependencyViewerModel

  coffeescriptPattern = /^.*\.coffee$/
  madgeExtensions = ['.js', '.coffee']

  constructor: ->

    @dependsOnThis = [
      { name: "AnotherFile1" },
      { name: "SomeFile2" }
    ]

  setActiveEditor: (editor) ->
    if (@isTextEditor(editor) && @isCoffeeFile(editor.getPath()))
      @findModulesCurrentItemDependsOn(editor)

  findModulesCurrentItemDependsOn: (editor) ->
    pathToFile = editor.getPath()
    console.log("pathToFile = " + pathToFile)
    madge = new Madge(pathToFile, {extensions: madgeExtensions})
    keys = Object.keys(madge.tree)
    unless keys.length == 0
      currentModuleName = keys[0]
      @thisDependsOn = madge.tree[currentModuleName]
      @findModulesThatRequireCurrentItem(editor, currentModuleName)

  findModulesThatRequireCurrentItem: (editor, currentModuleName) ->
    directoryPath = editor.getDirectoryPath()
    console.log("directoryPath = " + directoryPath)
    madge = new Madge(directoryPath, {extensions: madgeExtensions})
    deps = madge.depends(currentModuleName)
    paths = []
    for moduleName in deps
      do (moduleName) ->
        modulePath = require.resolve(path.join(__dirname, moduleName))
        if path.isAbsolute modulePath
          modulePath = path.relative(directoryPath, modulePath)
        paths.push(modulePath)
    @dependsOnThis = paths

  isTextEditor: (editor) ->
    editor?.constructor?.name is 'TextEditor'

  isCoffeeFile: (fileName) ->
    fileName.match(coffeescriptPattern)
