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

        # the response, includes repetitions
        Ember.merge(
          response,
          {
            validResponse: not [null,undefined].contains(response.value)
            colors: @colorClasses("#{type}_#{name}")
            pips: if response.value then [1..response.value] else []
            repetitions: repetitions
            taken: repetitions.get("firstObject.active")
            hasDose: repetitions.get("firstObject.hasDose")
          }
        )

      {
        categoryName: Ember.I18n.t(type)
        type: type
        pippable: pippable
        responses: responses
      }
    .sortBy("type")

  ).property("trackableSections", "responsesData", "treatments.@each.active")

  actions:
    toggleNotes: ->
      @toggleProperty("show_notes") unless Em.isPresent(@get("notes"))

      # Set focus
      Em.run.next =>
        $textarea = $(".checkin-note-textarea")
        if @get("show_notes") and Em.isPresent($textarea)
          $textarea.focus()

      false

`export default mixin`
