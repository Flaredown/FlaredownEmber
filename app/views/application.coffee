`import Ember from 'ember'`

view = Ember.View.extend
  didInsertElement: -> $("body > .loading-spinner").hide()

`export default view`