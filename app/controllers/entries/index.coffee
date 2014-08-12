`import Ember from 'ember'`

controller = Ember.ArrayController.extend
  sortProperties: ["jsDate"]
  sortAscending: true
  
  savedEntries: Ember.computed ->
    @get("arrangedContent").rejectBy("id", null)
  .property("@each")
  
  chartData: Ember.computed ->
    @get("savedEntries").map((entry, i) -> {x: entry.get("jsDate"), y: entry.get("score")})
    # @get("savedEntries").map((entry, i) -> {x: i, y: entry.get("score")})
  .property("savedEntries")

`export default controller`