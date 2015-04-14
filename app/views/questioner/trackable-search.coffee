`import Ember from 'ember'`

view = Ember.View.extend

  init: ->
    @_super()

    # Watch the "name" field on the trackable type model
    Em.defineProperty @, "errors", Em.computed( ->
      @get("controller.errors.fields.#{@get("trackableType")}.name")
    ).property("controller.errors.fields.#{@get("trackableType")}.@each")


  templateName: "questioner/trackable-search"
  classNameBindings: ["formClass"]

  formClass: Em.computed(-> "form-#{@get("trackableType")}-search")

`export default view`