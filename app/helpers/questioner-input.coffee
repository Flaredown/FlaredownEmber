`import Ember from 'ember'`
helper = (kind, options) ->
  view = Ember.View.extend({templateName: "questioner/_#{kind}_input"}).create()
  Ember.Handlebars.helpers.view.call(@, view, options)

`export default Ember.Handlebars.makeBoundHelper(helper)`