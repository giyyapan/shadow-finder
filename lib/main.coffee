module.exports =
  config:
    ignoredNames:
      type: 'array'
      default: []
    searchAllPanes:
      description: "Whether to search through all open panes or just the active one. Holding shift inverts this setting."
      type: 'boolean'
      default: false
    preserveLastSearch:
      type: 'boolean'
      default: false
    useAlternateScoring:
      description: "Prefers run of consecutive characters, acronyms and start of words. (Experimental)"
      type: 'boolean'
      default: false

  activate: (state) ->
    @active = true

    atom.commands.add 'atom-workspace',
      'shadow-finder:toggle': =>
        @createShadowFinderView().toggle()

    process.nextTick => @startLoadPathsTask()

    for editor in atom.workspace.getTextEditors()
      editor.lastOpened = state[editor.getPath()]

    atom.workspace.observePanes (pane) ->
      pane.observeActiveItem (item) -> item?.lastOpened = Date.now()

  deactivate: ->
    if @shadowFinderView?
      @shadowFinderView.destroy()
      @shadowFinderView = null
    @projectPaths = null
    @stopLoadPathsTask()
    @active = false

  serialize: ->
    paths = {}
    for editor in atom.workspace.getTextEditors()
      path = editor.getPath()
      paths[path] = editor.lastOpened if path?
    paths

  createShadowFinderView: ->
    @stopLoadPathsTask()

    unless @shadowFinderView?
      ShadowFinderView  = require './shadow-finder-view'
      @shadowFinderView = new ShadowFinderView(@projectPaths)
      @projectPaths = null
    @shadowFinderView

  startLoadPathsTask: ->
    @stopLoadPathsTask()

    return unless @active
    return if atom.project.getPaths().length is 0

    PathLoader = require './path-loader'
    @loadPathsTask = PathLoader.startTask (@projectPaths) =>
    @projectPathsSubscription = atom.project.onDidChangePaths =>
      @projectPaths = null
      @stopLoadPathsTask()

  stopLoadPathsTask: ->
    @projectPathsSubscription?.dispose()
    @projectPathsSubscription = null
    @loadPathsTask?.terminate()
    @loadPathsTask = null
