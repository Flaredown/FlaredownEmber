`import Ember from 'ember'`

controller = Ember.Controller.extend #App.ProfileValidationsMixin, App.FormStatesMixin,
  init: -> 
    @_super()
    @get("setValidationsByName")
  
  isAuthenticated: Ember.computed ->
    @get("currentUser.model.id")
  .property("currentUser.model")

  resetFormProperties: "email password".w()
      
  redirectToTransition: ->
    attemptedTransition = @get("attemptedTransition")
    if attemptedTransition and attemptedTransition.targetName isnt "index"
      attemptedTransition.retry()
      @set("attemptedTransition", null)
    else 
      @transitionToRoute(FlaredownENV.afterLoginRoute)
    
  # credentialsObserver: Ember.observer ->
  #   if Ember.isEmpty(@get("loginId"))
  #     $.removeCookie("loginId")
  #   else
  #     $.cookie("loginId", @get("loginId"))
  # .observes("loginId")
  
  actions:    
    login: ->
      data = {}
      data["api_v#{FlaredownENV.apiVersion}_user"] = @getProperties("email", "password")

      $.ajax
        type: "POST"
        url: "#{FlaredownENV.apiNamespace}/users/sign_in.json"
        data: data
        context: @
        
        success: (response) ->
          # @set "controllers.currentUser.model", @store.createRecord("currentUser", response)
          
          @store.find("currentUser", 0).then(
            (currentUser) =>
              @set("currentUser.model", currentUser)
              @redirectToTransition()
            ,
            (response) =>
              console.log "!!! ERROR"
          )
        
        error: @errorCallback
          
    logout: ->
      $.ajax
        url: "#{FlaredownENV.apiNamespace}/users/sign_out.json"
        type: "DELETE"
        context: @
        success: (response) -> 
          @get("currentUser.pusherChannels").clear()
          App.reset()
          @transitionToRoute("login")
        error: (response) -> @transitionToRoute("login")
        
`export default controller`