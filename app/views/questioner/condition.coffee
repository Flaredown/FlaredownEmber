`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/_condition_input"
  classNames: ["checkin-condition"]

  actions:
    destroy: (condition) ->
      swal
        title: "Are you sure?",
        text: Ember.I18n.t("#{@get("controller.currentUser.locale")}.confirm_condition_remove", condition: condition.name)
        type: "warning"
        showCancelButton: true
        closeOnConfirm: true
        =>
          @get("controller").send("removeCondition", condition)


    add: (condition) ->
      @get("controller").send("addCondition", condition.name)

    save: ->
      @set("editing", false)
      # @get("controller").send("conditionEdited")


`export default view`