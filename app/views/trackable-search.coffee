`import Ember from 'ember'`
`import Select2View from './select2'`
`import config from '../config/environment'`

view = Select2View.extend
  placeholder: Ember.computed( -> "Search a #{@get("trackableType").capitalize()}" ).property("trackableType")
  formatted: (trackable) ->
    "#{trackable.text} -- #{trackable.count}"
  # classNames: ['input-xlarge']

  config: Ember.computed( ->
    {
      minimumInputLength: 2
      placeholder: @get("placeholder")
      formatResult: @get("formatted")
      ajax:
        url: (query) => "#{config.apiNamespace}/#{@get("trackableType")}s/search/#{query}"
        dataType: 'json'
        delay: 300
        results: (response) -> {
          results: response.map (item,i) -> {id: i, text: item.name, count: item.count}
        }
        cache: true
    }
  ).property("trackableType")

  valueChanged: (->
    Ember.run.scheduleOnce('afterRender', @, 'processChildElements') if $(@).state is "inDOM" and Em.isPresent(@get("value"))
  ).observes("value")

  didInsertElement:     -> Ember.run.scheduleOnce('afterRender', @, 'processChildElements')
  processChildElements: -> @$().select2(@get("config"))
  willDestroyElement:   -> @$().select2("destroy")

`export default view`