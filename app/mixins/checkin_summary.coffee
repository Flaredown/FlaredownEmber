`import Ember from 'ember'`
`import colorableMixin from '../mixins/colorable'`

mixin = Ember.Mixin.create Em.I18n.TranslateableProperties, colorableMixin,

  trackableResponses: Em.computed( ->

    @get("trackableSections").map (type) =>
      singular_type = type.slice(0,-1)
      pippable = type isnt "treatments"

      key = if pippable then "responsesData" else type

      responses = @get(key)
      responses = responses.filterBy("catalog", type) if pippable

      # uniq them up by name (treatments can have duplicates)
      responses = responses.mapBy("name").uniq().map (name) =>

        repetitions = responses.filterBy("name",name)
        response = repetitions.get("firstObject").getProperties("name", "value")

        color = if type is "conditions" then "bg-default" else @colorClasses("#{type}_#{name}", singular_type).bg

        # the response, includes repetitions
        Ember.merge(
          response,
          {
            colorClass: color
            pips: if response.value then [1..response.value-1] else []
            repetitions: repetitions
          }
        )

      {
        categoryName: Ember.I18n.t(type)
        type: type
        pippable: pippable
        responses: responses
      }
    .sortBy("type")

  ).property("trackableSections", "responsesData", "treatments")

  actions:
    toggleNotes: -> @toggleProperty("show_notes"); false

`export default mixin`
