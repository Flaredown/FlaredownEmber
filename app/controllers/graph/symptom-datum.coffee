`import Ember from 'ember'`

controller = Ember.ObjectProxy.extend

  # Initial attributes should be: day, catalog, order, name, type
  fixed:           false
  start_xBinding:  "day"

  id: Ember.computed(-> "#{@get("day")}_#{@get("order")}").property("day", "order")
  text: Ember.computed(-> "#{moment.utc(@get('date')).format('MM/DD')} - #{@get('y')}" ).property("x", "y")
  classes: Ember.computed(-> "" ).property("type")

  entryDate: Ember.computed( -> moment.utc(@get("day")*1000).format("MMM-DD-YYYY") ).property("day")

`export default controller`