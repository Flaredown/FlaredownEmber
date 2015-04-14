`import Ember from 'ember'`

mixin = Ember.Mixin.create

  errors: null

  errorCallback: (response, controller) ->
    @resetErrors()

    if typeof response.jqXHR isnt "undefined"
      response = response.jqXHR.responseJSON

    console.log response
    switch response.errors.kind
      when "inline"
        @set("errors", response.errors)
      when "general"
        @handleGeneralErrors(response.errors.title, response.errors.description)
      when "generic"
        @handleGenericErrors(response.errors.title, response.errors.description)

  # handleInlineErrors: (errors)->

  handleGeneralErrors: (title, description) -> sweetAlert(Ember.I18n.t("nice_errors.#{title}"), Ember.I18n.t("nice_errors.#{description}"), "error")

  handleGenericErrors: (title, description) ->
    title = "#{title} Error"
    sweetAlert(title, Ember.I18n.t(description), "error")

  resetErrors: -> @set("errors", null)

`export default mixin`
