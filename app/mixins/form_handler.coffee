`import Ember from 'ember'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

mixin = Ember.Mixin.create GroovyResponseHandlerMixin,

  init: ->
    @_super()

    @set("fields"      , Ember.A([])) unless Em.isPresent @get("fields")        # all fields
    @set("requirements", Ember.A([])) unless Em.isPresent @get("requirements")  # fields that are required to have a value
    @set("validations" , Ember.A([])) unless Em.isPresent @get("validations")   # validations to be checked
    @set("subForms"    , Ember.A([])) unless Em.isPresent @get("subForms")      # validations sent from subcomponents

    @setProperties
      saving:       false
      errors:       null

    @set("defaults", {}) unless @get("defaults") # default values, in key/value format

    # Setup any default values
    Ember.keys(@get("defaults")).forEach (key) => @set(key, @get("defaults.#{key}"))

    # Watch all fields that can take inline errors and reset those errors upon field change
    @get("errorables").forEach (key) =>
      @addObserver(key, => @resetErrorsOn(key)) if Ember.typeOf(@get(key)) isnt 'function'
      @addObserver(key, => @resetErrorsOn(key,@get("modelClass"))) if Ember.typeOf(@get(key)) isnt 'function'

    # TODO: original intention was for Questioner "global" errors, currently commented as well
    # Em.defineProperty @, "allErrors", Em.computed("errors.fields.@each", "errors.fields.#{@get("errors.model")}}.@each", ->
    #   return [] unless @get("errors")
    #   _all = []
    #   root = "errors.fields"
    #   fields = Ember.keys(@get("errors.fields"))
    #
    #   console.log "?!?!"
    #   if @get("errors.model") and @get("errors.fields.#{@get("errors.model")}")
    #     root = "errors.fields.#{@get("errors.model")}"
    #     fields.push Ember.keys(@get("errors.fields.#{@get("errors.model")}"))
    #
    #   fields.forEach (field) => _all.pushObjects @get("#{root}.#{field}")
    #   _all
    #
    # )

  errorResponseTemplate: -> {
    errors: {
      kind: "inline"
      fields: {}
    }
  }

  errorables: (-> @get("requirements").concat(@get("validations")) ).property("requirements", "validations")

  hasChecks: Ember.computed(-> @get("requirements").length + @get("validations").length + @get("subForms").length ).property("requirements.@each", "validations.@each", "subForms.@each")

  niceName: (key) -> if @get("translationRoot") then Em.I18n.t("#{@get("translationRoot")}.#{key.underscore()}") else key
  checkFields: Em.computed ->
    pass      = true
    response  = @get("errorResponseTemplate")()

    @get("requirements").forEach (key) =>
      unless Em.isPresent(@get(key))
        pass = false

        error = { kind: "required", message: Em.I18n.t("nice_errors.field_required", {field: @niceName(key)}) }
        response.errors.fields[key] = []
        response.errors.fields[key].addObject error

    @get("validations").forEach (key) =>
      if response.errors.fields[key] is undefined and Em.isPresent(@get(key)) and not @get("#{key}Valid")
        pass = false

        error = { kind: "invalid", message: Em.I18n.t("nice_errors.field_invalid", {field:  @niceName(key)}) }
        response.errors.fields[key] = []
        response.errors.fields[key].addObject error

    @get("subForms").forEach (form) => # simply check that these pass
      pass = false if not form.get("isDestroyed") and not form.saveForm()

    @errorCallback(response) unless pass
    pass

  .property("requirements.@each", "validations.@each", "subForms.@each").volatile()

  resetErrorsOn: (key,model) ->
    if @get("errors.fields")
      if model and @get("errors.fields.#{model}")
        @set("errors.fields.#{model}.#{key}", [])
      else
        @set("errors.fields.#{key}", [])

  saveForm: (skipSavableCheck) ->
    @set("errors", null)
    skipSavableCheck = false if typeof(skipSavableCheck) is "undefined"
    return false if @get("hasChecks") and not @get("checkFields")
    # return false if not skipSavableCheck and not @get("isSavable")

    @set "saving", true
    @get("saving")

  endSave: (reset) ->
    @set "saving", false
    true

`export default mixin`

