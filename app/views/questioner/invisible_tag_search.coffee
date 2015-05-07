`import Ember from 'ember'`
`import Select2View from '../forms/select2'`
`import config from '../../config/environment'`


view = Select2View.extend

  formatted: (trackable) ->
    if trackable.count isnt null
      "<span class='name'>#{trackable.text}</span><div class='count'>used #{trackable.count} time(s) before</div>"
    else
      prompt = Ember.I18n.t("#{@get("currentUser.locale")}.add_tag_prompt")
      "<span class='name'>\"#{trackable.text}\"</span><div class='count'>#{prompt}</div>"

  classNames: ['invisible-tag-search', "note-tag-search"]

  reset: -> @rerender() # start from scratch with blank search
  selected: (event) -> $(".checkin-note-textarea .hashtag.current").text("##{event.choice.text}")
  closed:   (event) -> @reset()

  config: Ember.computed( ->
    {
      minimumResultsForSearch: 1
      placeholder: @get("placeholder")
      formatResult: @get("formatted").bind(@)
      dropdownCssClass: "tag-search"
      containerCssClass: "tag-search"
      # formatInputTooShort: -> Em.I18n.t("forms.keep_typing")
      opts:
        shouldFocusInput: false

      initSelection: ((el,callback) -> callback(null) ).bind(@)
      ajax:
        transport: Ember.$.ajax
        url: (query) => "#{config.apiNamespace}/tags/search/#{query}"
        dataType: 'json'
        delay: 0
        results: (response, _, original) ->
          formatted_results = response.map (item,i) ->
            {id: i+1, text: item.name, count: item.count }
          , @

          if Ember.isPresent(formatted_results)
            original.element.addClass("has-results")
            { results: formatted_results }
          else
            original.element.select2("close")
            original.element.removeClass("has-results")
        cache: true
    }
  ).property()

`export default view`