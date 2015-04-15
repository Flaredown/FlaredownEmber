`import Ember from 'ember'`

controller = Ember.Controller.extend
  translationRoot: "onboarding"

  catalogDescriptions: Ember.computed( ->
    Ember.keys(@get("model")).map (catalog) =>
      {
        title: Em.I18n.t("catalogs.#{catalog}.catalog_description")
        sections: [1..@get("model.#{catalog}.length")].map (section) -> Em.I18n.t("catalogs.#{catalog}.section_#{section}_description")
      }
  ).property("model.@each")

`export default controller`