`import Ember from 'ember'`

controller = Ember.ObjectProxy.extend
  # dataBinding: "controller.scoreData"

  # Initial attributes should be: day, catalog, order, name, type
  fixed:           false
  # start_y:         1000
  start_xBinding:  "day"

  id: Ember.computed(-> "#{@get("day")}_#{@get("order")}").property("day", "order")
  scoreText: Ember.computed(->
    "10"
    # switch @get("type")
    #   when "normal"
    #     if @get("origin.y") is -1
    #       return "!"
    #     else
    #       return @get("y")
    #   when "missing" then "?"
  )
  text: Ember.computed(-> "#{moment.utc(@get('date')).format('MM/DD')} - #{@get('y')}" ).property("x", "y")
  classes: Ember.computed(->
    ""
    # switch @get("type")
    #   when "normal"
    #     if @get("origin.y") is -1
    #       return "incomplete"
    #     else
    #       return ""
    #   when "missing" then return "missing"

  ).property("type")

  entryDate: Ember.computed ->
    moment.utc(@get("day")*1000).format("MMM-DD-YYYY")
  .property("day")

  # objectFormat: Ember.computed ->
  #   Ember.Object.create @getProperties("id", "text", "index", "origin", "scoreText")
  # .property()


  # d3Format: Ember.computed ->
  #   Ember.Object.create(@getProperties("id", "text", "index", "origin", "scoreText", "classes")).setProperties fixed: false, start_x: @get("x"), model: @
  # .property()

`export default controller`