`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/_condition_input"
  classNames: ["checkin-condition"]

  actions:
    remove: (condition) ->
      @set("controller.lastSave", false)
      @get("controller").send("removeCondition", condition)
    destroy: (condition) ->
      if @get("controller.isPast")
        @send("remove", condition)
      else
        swal
          title: "Are you sure?",
          text: Ember.I18n.t("confirm_condition_remove", condition: condition.name)
          type: "warning"
          showCancelButton: true
          closeOnConfirm: true
          => @send("remove", condition)

    add: (condition) ->
      @set("controller.lastSave", false)
      @get("controller").send("addCondition", condition.name)

    save: ->
      @set("editing", false)
      # @get("controller").send("conditionEdited")


`export default view`