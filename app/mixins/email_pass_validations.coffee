`import Ember from 'ember'`

mixin = Ember.Mixin.create

  emailValid: Em.computed( ->
    email_regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    email_regex.test(@get("email"))
  ).property("email")

  passwordValid: Em.computed( -> @get("password.length") >= 2 ).property("password")
  password_confirmationValid: Em.computed( -> @get("password_confirmation") is @get("password") ).property("password_confirmation", "password")


`export default mixin`


