`import Ember from 'ember'`
`import Select2View from '../forms/select2'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`

view = Select2View.extend

  classNameBindings: ["formClass"]
  formClass: Em.computed(-> "form-#{@get("trackableType")}-select")

  placeholder: Ember.computed( -> "Add a #{@get("trackableType")}" ).property("trackableType")
  formatted: (trackable) ->
    if trackable.count isnt null
      "<span class='name'>#{trackable.text}</span><div class='count'>#{trackable.count} users</div>"
    else
      prompt = Ember.I18n.t("add_trackable_prompt",kind: @get("trackableType"))
      "<span class='name'>\"#{trackable.text}\"</span><div class='count'>#{prompt}</div>"

  opened: (event) ->
    @_super()
    @get("controller").resetErrorsOn(@get("trackableType"))

  selected: (event) ->
    if @get("open")
      trackable = if @get("trackableType") is "treatment"
        {name: event.choice.text, quantity: null, unit: null, added: true}
      else
        {name: event.choice.text}

      @get("controller").send("add#{@get("trackableType").capitalize()}", trackable)
      @rerender() # start from scratch with blank search

  existingTrackables: Ember.computed( ->
    @get("controller.#{@get("trackableType")}s").mapBy("name")
  ).property("trackableType", "controller.treatments.@each", "controller.symptoms.@each", "controller.conditions.@each")

  config: Ember.computed( ->
    {
      minimumInputLength: 3
      placeholder: @get("placeholder")
      formatResult: @get("formatted").bind(@)
      formatInputTooShort: -> Em.I18n.t("forms.keep_typing")
      ajax:
        existingTrackables: (=> @get("existingTrackables"))
        transport: Ember.$.ajax
        url: (query) => "#{config.apiNamespace}/#{@get("trackableType")}s/search/#{query}"
        dataType: 'json'
        delay: 300
        results: (response, _, original) ->
          formatted_results = [{id: 0, text: original.term, count: null}]

          formatted_results.addObjects response.map (item,i) ->
            {id: i+1, text: item.name, count: item.count, disabled: @existingTrackables().contains(item.name)}
          , @

          {
            results: formatted_results
          }
        cache: true
    }
  ).property("trackableType", "existingTrackables")

  valueChanged: (->
    Ember.run.scheduleOnce('afterRender', @, 'processChildElements') if $(@).state is "inDOM" and Em.isPresent(@get("value"))
  ).observes("value")

`export default view`