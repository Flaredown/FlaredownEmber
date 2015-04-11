`import Ember from 'ember'`

view = Ember.View.extend
  # prompt: 'Please select...'
  # classNames: ['input-xlarge']
  tagName: "input"

  config: Ember.computed( ->
    {
      data: @get("content")
    }
  ).property("content")

  selected: (event) -> @set("value", event.choice.text)
  closed: (event) ->

  didInsertElement: ->
    Ember.run.scheduleOnce('afterRender', @, 'processChildElements')
    @$().on("select2-selecting", @selected.bind(@))
    @$().on("select2-close", @closed.bind(@))

  processChildElements: -> @$().select2(@get("config"))
  willDestroyElement: -> @$().select2("destroy")

`export default view`