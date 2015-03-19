`import Ember from 'ember'`
`import Select2View from '../select2'`
`import config from '../../config/environment'`


view = Select2View.extend

  formatted: (trackable) ->
    if trackable.count isnt null
      "<span class='name'>#{trackable.text}</span><div class='count'>used #{trackable.count} time(s) before</div>"
    else
      prompt = Ember.I18n.t("#{@get("currentUser.locale")}.add_tag_prompt")
      "<span class='name'>\"#{trackable.text}\"</span><div class='count'>#{prompt}</div>"

  classNames: ['tag-search']
  elementId: "note-tag-search"

  reset: -> @rerender() # start from scratch with blank search
  selected: (event) -> @reset()
  closed:   (event) -> @reset()

  config: Ember.computed( ->
    {
      minimumInputLength: 2
      placeholder: @get("placeholder")
      formatResult: @get("formatted").bind(@)
      # formatInputTooShort: -> "Keep typing..."
      opts:
        shouldFocusInput: false

      initSelection: ((el,callback) -> callback(null) ).bind(@)
      ajax:
        transport: Ember.$.ajax
        url: (query) => "#{config.apiNamespace}/tags/search/#{query}"
        dataType: 'json'
        delay: 0
        results: (response, _, original) ->

          formatted_results = [{id: 0, text: original.term, count: null}]

          formatted_results.addObjects response.map (item,i) ->
            {id: i+1, text: item.name, count: item.count }
          , @

          {
            results: formatted_results
          }
        cache: true
    }
  ).property()

  # config: Ember.computed( ->
  #   {
  #     minimumSearchResults: 1
  #     initSelection: ((el,callback) -> callback({id:0, text: @get("value")}) ).bind(@)
  #     data: @get("content")
  #     createSearchChoice: ((term) -> {id: 0, text: term} unless @get("content").mapBy("text").contains(term) ).bind(@)
  #   }
  #
  # ).property("content")

`export default view`