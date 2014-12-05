`import Ember from 'ember'`

component = Ember.Component.extend
  templateName: Ember.computed(->
    "questioner/_#{@get("question.kind")}_input"
  ).property()

  actions:
    sendResponse: (name, value) ->
      @sendAction("action", name, value)

`export default component`