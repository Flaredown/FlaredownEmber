`import Ember from 'ember'`
`import Select2View from '../select2'`

view = Select2View.extend

  content: Ember.computed( -> Ember.I18n.translations.treatment_units.map (unit,i) -> {id:i+1, text: unit} ).property("value")

  config: Ember.computed( ->
    {
      initSelection: ((el,callback) -> callback({id:0, text: @get("value")}) ).bind(@)
      data: @get("content")
      createSearchChoice: ((term) -> {id: 0, text: term} unless @get("content").mapBy("text").contains(term) ).bind(@)
    }

  ).property("content")

`export default view`