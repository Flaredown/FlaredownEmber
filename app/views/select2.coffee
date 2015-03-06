`import Ember from 'ember'`

view = Select2View = Ember.View.extend
  # prompt: 'Please select...'
  # classNames: ['input-xlarge']
  tagName: "input"

  config: {}

  valueChanged: (->
    Ember.run.scheduleOnce('afterRender', @, 'processChildElements') if $(@).state is "inDOM"
  ).observes("value")

  didInsertElement: ->
    Ember.run.scheduleOnce('afterRender', @, 'processChildElements')

  processChildElements: ->
    if @get("noSearch")
      @$().select2
        minimumResultsForSearch: -1
    else
      @$().select2(@get("config"))
        # do here any configuration of the
        # select2 component

  willDestroyElement: ->
    @$().select2("destroy")

`export default view`