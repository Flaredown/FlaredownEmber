helperFunctions = ->
  window.assertModalPresent = -> ok($(".ember-modal-dialog").length, "Modal shows up")

  window.assertAlertPresent = (confirm) ->
    confirm = false if typeof(confirm) is "undefind"
    ok($(".showSweetAlert").length, "Alert shows up") # Sweet Alert element falls outside test container, using $ to find it

    unless confirm
      $(".sweet-alert").remove()
      $(".sweet-overlay").remove()
    sweetAlertInitialize() # put it back

`export default helperFunctions`