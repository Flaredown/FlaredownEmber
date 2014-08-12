`import Ember from 'ember'`
`import DS from 'ember-data'`

appHelpers = ->
  # Progress Bar
  Ember.$(document).ajaxStart ->
    $("#progress").remove()
    if $("#progress").length is 0
      $("body").append(Ember.$("<div><dt/><dd/></div>").attr("id", "progress"))
      $("#progress").width((50 + Math.random() * 30) + "%")

  Ember.$(document).ajaxComplete ->
    # End loading animation
    Ember.$("#progress").width("110%") #.delay(200).fadeOut 400,
    Ember.$("#progress").html("")
  
  window.uuid = (name, doc_id) ->
    "#{name}_#{doc_id}"
  
  window.attr      = DS.attr
  window.belongsTo = DS.belongsTo
  window.hasMany   = DS.hasMany

  window.ajax = (url, options) ->
    new Ember.RSVP.Promise((resolve, reject) ->
      options = options or {}
      options.url = url
      options.success = (data) ->
        Ember.run.once null, resolve, data
        return

      options.error = (jqxhr, status, something) ->
        Ember.run.once null, reject, arguments
        return

      Ember.$.ajax options
    )


  # Ember.$.ajaxSetup
  #   contentType: "application/json; charset=utf-8"
  #   dataType: "json"
  #   beforeSend: (xhr, settings) ->
  #     csrf_token = $('meta[name="csrf-token"]').attr('content');
  #     if csrf_token then xhr.setRequestHeader('X-CSRF-Token', csrf_token)
  #     if ( settings.contentType is "application/json; charset=utf-8" and typeof(settings.data) isnt "string" )
  #       settings.format = "json"
  #       settings.data = JSON.stringify(settings.data)
      
  # window.App.generalError = (message) ->
  #   unless message then message = "We've encountered an unexpected error! Please refresh the page and try again, if the error persists please contact support via the 'Contact Us' link."
  #   alert(message)
  
`export default appHelpers`