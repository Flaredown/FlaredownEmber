`import Ember from 'ember'`

helper = Ember.Handlebars.makeBoundHelper (value) ->
  escaped = Handlebars.Utils.escapeExpression(value);
  Ember.I18n.t("nice_errors.#{escaped}")

`export default helper`