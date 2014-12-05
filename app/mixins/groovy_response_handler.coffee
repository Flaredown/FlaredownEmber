`import Ember from 'ember'`

mixin = Ember.Mixin.create

  errors : null # to hold all errors

  error_group : null # to hold namespace of errors we are dealing with

  proxy : null

  ##
  # acts like a sort of constructor for
  # initializing errors, inspired from eVisit's form_state_mixin
  ##
  errorCallback : (response, controller) ->
    @setupProxy(controller)
    if typeof response.jqXHR isnt "undefined"
      response = response.jqXHR.responseJSON
    @set("errors", response.errors)
    @set("error_group", response.errors.error_group)
    switch @get("error_group")
      when "inline"
        @handleInlineErrors()

  handleInlineErrors : ->
    fields = Object.keys(@errors.fields)
    for field in fields
      @proxy.set("#{field}Error", true)
      @proxy.set("#{field}Messages", @errors.fields[field])



  setupProxy : (controller) ->
    proxy = Ember.ObjectProxy.create
      content: controller

    @set('proxy', proxy)

`export default mixin`
