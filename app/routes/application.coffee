`import Ember from 'ember'`

route = Ember.Route.extend

  actions:
    entry_processed: (data) -> @controllerFor("graph").send("dayProcessed", data.entry_date)

`export default route`

