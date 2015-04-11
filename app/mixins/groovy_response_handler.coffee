`import Ember from 'ember'`

mixin = Ember.Mixin.create

  errors : null # to hold all errors

  error_group : null # to hold namespace of errors we are dealing with

  proxy : null # holds the proxy object of controller to add dynamic properties

  modalOpen: false # modal flag to toggle modal in case of modal errors

  ##
  # modalOpen observer
  # hides modal if it is open
  ##

  # modalChanged: Ember.observer ->
  #   unless @get("modalOpen")
  #     @set("modalOpen", false)
  # .observes("modalOpen")

  ##
  # acts like a sort of constructor for
  # initializing errors, inspired from eVisit's form_state_mixin
  ##

  errorCallback : (response, controller) ->
    @resetErrors()
    @setupProxy(controller)
    if typeof response.jqXHR isnt "undefined"
      response = response.jqXHR.responseJSON
    @set("errors", response.errors)
    @set("error_group", response.errors.error_group)
    switch @get("error_group")
      when "inline"
        @handleInlineErrors()
      when "modal"
        @handleModalErrors()
      when "growl"
        @handleGrowlErrors()

  handleInlineErrors : ->
    fields = Object.keys(@errors.fields)
    for field in fields
      @get("proxy").set("#{field}Error", true)
      @get("proxy").set("#{field}Messages", @errors.fields[field])

  handleModalErrors : ->
    @proxy.set("modal_error_title", @errors.title)
    @proxy.set("modal_error_message", @errors.message)
    @set("modalOpen", true)

  handleGrowlErrors : ->
    sweetAlert(@errors.title, @errors.message, @errors.error)


  resetErrors : () ->
    @set("errors", null)
    if @get("proxy") isnt null
      @get("proxy").destroy()
    # @set("modalOpen", false)

  setupProxy : (controller) ->
    content = if typeof controller is "undefined" then {} else controller

    proxy = Ember.ObjectProxy.create
      content: content

    @set('proxy', proxy)

`export default mixin`
