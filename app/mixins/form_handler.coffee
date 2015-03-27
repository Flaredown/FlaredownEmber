`import Ember from 'ember'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

mixin = Ember.Mixin.create GroovyResponseHandlerMixin,

  errorResponseTemplate: -> {
    errors: {
      kind: "inline"
      fields: {}
    }
  }

  requirements: [] # fields that are required to have a value
  validations:  [] # validations to be checked

  hasChecks: Ember.computed(-> @get("requirements").length or @get("validations").length ).property("requirements", "validations")

  checkFields: ->
    pass      = true
    response  = @get("errorResponseTemplate")()

    @get("requirements").forEach (key) =>
      unless Em.isPresent(@get(key))
        pass = false

        error = { kind: "required", message: "The field #{key.capitalize()} is required"} # TODO needs I18n with placeholder
        response.errors.fields[key] = []
        response.errors.fields[key].addObject error

    @get("validations").forEach (key) =>
      if response.errors.fields[key] is undefined and not @get("#{key}Valid")
        pass = false

        error = { kind: "invalid", message: "The field #{key.capitalize()} is not valid"} # TODO needs I18n with placeholder
        response.errors.fields[key] = []
        response.errors.fields[key].addObject error

    @errorCallback(response, @) unless pass
    pass

  saveForm: (skipSavableCheck) ->
    @resetErrors()

    skipSavableCheck = false if typeof(skipSavableCheck) is "undefined"
    return false if @get("hasChecks") and not @checkFields()
    return false if not skipSavableCheck and not @get("isSavable")

    @set "saving", true
    @get("saving")

  endSave: (reset) ->
    # reset = true if typeof(reset) is "undefined"
    # @resetForm() if reset
    @set "saving", false


`export default mixin`

