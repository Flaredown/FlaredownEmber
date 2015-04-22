`import Ember from 'ember'`

mixin = Ember.Mixin.create

  errors: null
  saving: false

  errorCallback: (response) ->

    unless Em.typeOf(@) is "object" # Not suitable for form handling stuff
      @set("errors", null)
      @set("saving", false)

    if typeof response.jqXHR isnt "undefined"
      response = response.jqXHR.responseJSON
    else if typeof response.responseJSON isnt "undefined"
      response = response.responseJSON
    # else
    #   response = @genericFiveHundred()

    switch response.errors.kind
      when "inline"
        @set("errors", response.errors)
      when "general"
        @handleGeneralErrors(response.errors.title, response.errors.description)
      when "generic"
        @handleGenericErrors(response.errors.title, response.errors.description)

  # handleInlineErrors: (errors)->

  handleGeneralErrors: (title, description) ->
    if Em.keys(Ember.I18n.translations).length and Ember.I18n.translations.get("nice_errors.#{title}")
      sweetAlert(Ember.I18n.t("nice_errors.#{title}"), Ember.I18n.t("nice_errors.#{description}"), "error")
    else
      sweetAlert(title, description, "error")

  handleGenericErrors: (title, description) ->
    title = "#{title} Error"
    sweetAlert(title, Ember.I18n.t(description), "error")
    sweetAlert(title, description, "error")

  genericFiveHundred: ->
    Ember.Object.create
      errors:
        kind:
          title: "500"
          description: "500_description"

`export default mixin`
