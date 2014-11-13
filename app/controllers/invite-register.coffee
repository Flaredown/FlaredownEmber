`import Ember from 'ember'`

controller = Ember.ObjectController.extend

  errors: {}

  reset: ->
    @setProperties
      email: ""
      password: ""
      password_confirmation: ""
      country: ""

  actions:
    register: ->
      self = @
      data = {user: @getProperties("email", "password", "password_confirmation", "country")}

      @set('errors', {})

      Ember.$.ajax(
        type: "POST"
        url: "/users.json"
        data: data
        contentType: "application/x-www-form-urlencoded; charset=UTF-8"
      ).then(
        (response) ->
            # self.set "controllers.login.loginId", response.id
            self.set "controllers.user.content", response
            self.reset()
            self.transitionToRoute('entries')

        (response) ->
            errors = JSON.parse(response.responseText).errors

            for k,v of errors
              errors[k] = v[0]

            self.set("errors", errors)
      )


`export default controller`