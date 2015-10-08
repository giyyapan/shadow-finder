module.exports =
class BaseFinder
  view:null

  constructor:(@view)->
    @initialize()

  initialize:->

  getEmptyMessage:->
    "There's nothing to show"

  destroy:->
