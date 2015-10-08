FuzzyFinderView = require './fuzzy-finder-view'
FileFinder = require './file-finder'
BufferFinder = require './buffer-finder'
SymbolFinder = require './symbol-finder'

module.exports =
class ShadowFinderView extends FuzzyFinderView
  initialize: (@paths) ->
    super
    @fileFinder = new FileFinder this
    @bufferFinder = new BufferFinder this
    @symbolFinder = new SymbolFinder this
    @finders = [ @fileFinder, @bufferFinder, @symbolFinder ]
    @currentFinder = @fileFinder

  updateFinder:()->
    filterQuery = @getFilterQuery()
    finder = null
    switch filterQuery[0]
      when '@' then finder = @bufferFinder
      when '#' then finder = @symbolFinder
      else finder = @fileFinder
    if finder isnt @currentFinder
      @currentFinder = finder
      @populate()

  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else
      @populate()
      @show() if @paths?.length > 0

  projectRelativePathsForFilePaths:->
    if @currentFinder.projectRelativePathsForFilePaths
      @currentFinder.projectRelativePathsForFilePaths
    else
      super

  getEmptyMessage: (itemCount) ->
    @currentFinder.getEmptyMessage()

  populate: ->
    @updateFinder()
    @currentFinder.populate()

  destroy:->
    finder.destroy() for finder in @finders
