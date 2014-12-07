`import Ember from 'ember'`

controller = Ember.Controller.extend
  # dataBinding: "controller.scoreData"

  scoreText: Ember.computed(->
    switch @get("type")
      when "normal"
        if @get("origin.y") is -1
          return "!"
        else
          return @get("y")
      when "missing" then "?"
  )
  text: Ember.computed(-> "#{moment.utc(@get('date')).format('MM/DD')} - #{@get('y')}" ).property("x", "y")
  classes: Ember.computed(->
    switch @get("type")
      when "normal"
        if @get("origin.y") is -1
          return "incomplete"
        else
          return ""
      when "missing" then return "missing"

  ).property("type")

  entryDate: Ember.computed ->
    moment.utc(@get("date")*1000).format("MMM-DD-YYYY")
  .property("x")

  # objectFormat: Ember.computed ->
  #   Ember.Object.create @getProperties("id", "text", "index", "origin", "scoreText")
  # .property()

  d3Format: Ember.computed ->
    Ember.Object.create(@getProperties("id", "text", "index", "origin", "scoreText", "classes")).setProperties fixed: false, startx: @get("x"), model: @
  .property()

  goTo: -> @get("controller").transitionToRoute("entries.checkin", @get("entryDate"), 1)

`export default controller`