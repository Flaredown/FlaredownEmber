`import Ember from 'ember'`

view = Ember.View.extend
  templateName: "forms/errors"
  errors: Em.computed.alias("parentView.errors")
`export default view`