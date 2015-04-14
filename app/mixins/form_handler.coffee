`import Ember from 'ember'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

mixin = Ember.Mixin.create GroovyResponseHandlerMixin,

  init: ->
    @_super()
    @setProperties
      saving:       false
      errors:       null

    @set("defaults", {}) unless @get("defaults") # default values, in key/value format

    # Setup any default values
    Ember.keys(@get("defaults")).forEach (key) => @set(key, @get("defaults.#{key}"))

    # Watch all fields that can take inline errors and reset those errors upon field change
    @get("errorables").forEach (key) =>
      @addObserver(key, => @resetErrorsOn(key,@get("modelClass"))) if Ember.typeOf(@get(key)) isnt 'function'

  errorResponseTemplate: -> {
    errors: {
      kind: "inline"
      fields: {}
    }
  }

  fields:       [] # all fields
  requirements: [] # fields that are required to have a value
  validations:  [] # validations to be checked

  errorables: (-> @get("requirements").concat(@get("validations")) ).property("requirements", "validations")

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
      if response.errors.fields[key] is undefined and Em.isPresent(@get(key)) and not @get("#{key}Valid")
        pass = false

        error = { kind: "invalid", message: "The field #{key.capitalize()} is not valid"} # TODO needs I18n with placeholder
        response.errors.fields[key] = []
        response.errors.fields[key].addObject error

    @errorCallback(response, @) unless pass
    pass

  resetErrorsOn: (key,model) ->
    if @get("errors.fields")
      if model
        @set("errors.fields.#{model}.#{key}", [])
      else
        @set("errors.fields.#{key}", [])

  saveForm: (skipSavableCheck) ->
    @resetErrors()

    skipSavableCheck = false if typeof(skipSavableCheck) is "undefined"
    return false if @get("hasChecks") and not @checkFields()
    # return false if not skipSavableCheck and not @get("isSavable")

    @set "saving", true
    @get("saving")

  endSave: (reset) ->
    # reset = true if typeof(reset) is "undefined"
    # @resetForm() if reset
    @set "saving", false
    true


`export default mixin`

