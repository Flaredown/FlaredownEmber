`import Ember from 'ember'`
`import Select2View from './select2'`
`import config from '../config/environment'`

view = Select2View.extend
  placeholder: Ember.computed( -> "Search a #{@get("trackableType").capitalize()}" ).property("trackableType")
  formatted: (trackable) ->
    if trackable.count isnt null
      "<span class='name'>#{trackable.text}</span><div class='count'>#{trackable.count} users</div>"
    else
      prompt = Ember.I18n.t("#{@get("currentUser.locale")}.add_trackable_prompt",kind: @get("trackableType"))
      "<span class='name'>#{trackable.text}</span><div class='count'>#{prompt}</div>"

  # classNames: ['input-xlarge']

  config: Ember.computed( ->
    {
      minimumInputLength: 3
      placeholder: @get("placeholder")
      formatResult: @get("formatted").bind(@)
      formatInputTooShort: -> "Keep typing..."
      ajax:
        url: (query) => "#{config.apiNamespace}/#{@get("trackableType")}s/search/#{query}"
        dataType: 'json'
        delay: 300
        results: (response, _, original) ->
          formatted_results = [{id: 0, text: original.term, count: null}]
          formatted_results.addObjects response.map (item,i) -> {id: i+1, text: item.name, count: item.count}
          {
            results: formatted_results
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