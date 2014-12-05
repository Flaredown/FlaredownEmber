`import Ember from 'ember'`

mixin = Ember.Mixin.create

  errors : null # to hold all errors

  error_group : null # to hold namespace of errors we are dealing with

  ##
  # acts like a sort of constructor for
  # initializing errors, inspired from eVisit's form_state_mixin
  ##
  errorCallback : (response) ->
    @set("errors", response.errors)
    @set("error_group", response.errors.error_group)

`export default mixin`
