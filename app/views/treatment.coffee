`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/_treatment_input"
  classNames: ["checkin-treatment"]

  editing: false

  actions:
    edit: -> @set("editing", true)
    destroy: (id) ->
      treatment = @get("controller.treatments").findBy("id", id)
      if window.confirm(Ember.I18n.t("#{@get("controller.currentUser.locale")}.confirm_treatment_remove", treatment: treatment.get("name")))
        @get("controller.treatments").removeObject(treatment)
    save: ->
      @set("editing", false)
      @get("controller").send("treatmentEdited")


`export default view`