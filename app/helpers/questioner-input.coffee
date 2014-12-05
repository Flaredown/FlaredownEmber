`import Ember from 'ember'`
helper = (kind, options) ->
  view = Ember.Component.extend({templateName: "questioner/_#{kind}_input"}).create()
  # TODO replace with this perhaps? https://github.com/minutebase/ember-dynamic-component
  # Ember.Handlebars.helpers.view.call(@view, view, options)
  ""

`export default Ember.Handlebars.makeBoundHelper(helper)`