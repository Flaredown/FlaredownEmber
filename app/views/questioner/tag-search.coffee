`import Ember from 'ember'`
`import Select2View from '../forms/select2'`
`import config from '../../config/environment'`

view = Select2View.extend

  formatted: (tag) ->
    if tag.count isnt null
      "<span class='name'>#{tag.text}</span><div class='count'>used #{tag.count} time(s) before</div>"
    else
      prompt = Ember.I18n.t("add_tag_prompt")
      "<span class='name'>\"#{tag.text}\"</span><div class='count'>#{prompt}</div>"

  classNames: ['tag-search']

  selected: (event) ->
    if @get("open")
      @get("controller.tags").addObject(event.choice.text)


      # @$().select2({ allowClear: true })

      Ember.run.later(
        =>
          @$().select2("data", null)
          @$().select2("search")
        20
      )
    else
      false

  closed:   (event) ->
    @set("open", false)

  config: Ember.computed( ->
    {
      minimumResultsForSearch: 1
      minimumInputLength: 3
      placeholder: Em.I18n.t("tag_search_placeholder")
      formatResult: @get("formatted").bind(@)
      allowClear: true
      # maximumInputLength: 20
      dropdownCssClass: "tag-search"
      containerCssClass: "tag-search"
      formatInputTooShort: -> Em.I18n.t("forms.keep_typing")

      initSelection: ((el,callback) -> callback(null) ).bind(@)
      ajax:
        transport: Ember.$.ajax
        url: (query) => "#{config.apiNamespace}/tags/search/#{query}"
        dataType: 'json'
        delay: 0
        cache: true
        results: (response, _, original) ->
          formatted_results = [{id: 0, text: original.term, count: null}]

          formatted_results.addObjects response.map (item,i) ->
            {id: i+1, text: item.name, count: item.count }
          , @

          {
            results: formatted_results
          }

    }
  ).property()

`export default view`