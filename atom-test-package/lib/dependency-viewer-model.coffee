path = require 'path'
{CompositeDisposable} = require 'atom'
{allowUnsafeNewFunction, allowUnsafeEval} = require 'loophole'
Madge = allowUnsafeNewFunction -> require 'madge'



module.exports =
class DependencyViewerModel

  coffeescriptPattern = /^.*\.coffee$/
  madgeExtensions = ['.js', '.coffee']

  constructor: ->
    @data = {
      thisDependsOn:[],
      dependsOnThis:[],
      currentModuleName:'',
      validFile:false,
      currentFileName:''
    }

  getData: ->
    console.log("getData() = " + JSON.stringify(@data))
    @data

  setActiveEditor: (editor) ->
    @editor = editor
    @findDependencies()

  emptyArrays: ->
    @data.thisDependsOn?.splice(0,@data.thisDependsOn.length)
    @data.dependsOnThis?.splice(0,@data.dependsOnThis.length)

  findDependencies: ->
    return unless @isTextEditor(@editor)

    @data.currentFileName = @editor.getTitle()

    if (@isCoffeeFile(@editor.getPath()))
      @pathToFile = @editor.getPath()
      @directoryPath = @editor.getDirectoryPath()
      @parsedDir = path.parse(@pathToFile)
      @data.currentModuleName = @currentModuleName = @parsedDir.name #name of file without extension
      @findModulesCurrentItemDependsOn()
      @data.validFile = true
    else
      console.log("data.currentFileName = " + @data.currentFileName)
      @emptyArrays()
      @data.validFile = false
      @data.currentModuleName = ''
    console.log("DATA = " + JSON.stringify(@data))

  findModulesCurrentItemDependsOn: ->
    console.log("pathToFile = " + @pathToFile)
    madge = new Madge(@pathToFile, {extensions: madgeExtensions})
    console.log("tree = " + JSON.stringify(madge?.tree))
    if @currentModuleName of madge.tree
      console.log("currentModuleName = " + @currentModuleName)
      @data.thisDependsOn = madge.tree[@currentModuleName]
      @findModulesThatRequireCurrentItem()

  findModulesThatRequireCurrentItem: ->
    console.log("directoryPath = " + @directoryPath)
    madge = new Madge(@directoryPath, {extensions: madgeExtensions})
    deps = madge.depends(@currentModuleName)
    paths = []
    for moduleName in deps
      do (moduleName) =>
        try
          console.log("moduleName = " + moduleName)
          modulePath = require.resolve(path.join(__dirname, moduleName))
          if modulePath? && path?.isAbsolute modulePath
            modulePath = path.relative(@directoryPath, modulePath)
          paths.push(modulePath)
        catch error
          console.log("ERROR: " + error)
          paths.push(moduleName)
    @data.dependsOnThis = paths

  isTextEditor: (editor) ->
    editor?.constructor?.name is 'TextEditor'

  isCoffeeFile: (fileName) ->
    fileName.match(coffeescriptPattern)

  moduleNameFromPath: (pathToModule) ->
    parts = path.sep(pathToModule)
    i = parts.indexOf('node_modules')
    if (i = -1) # path parts doesn't contain node_modules
      pathToModule
    else if (parts.length <= i + 1) # node_modules is somehow the last part
      pathToModule
    else
      parts[i+1]
