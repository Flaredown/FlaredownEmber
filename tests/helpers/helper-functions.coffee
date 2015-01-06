helperFunctions = ->
  window.assertModalPresent = ->
    ok($(".modal").length, "Modal shows up") # Sweet Alert element falls outside test container, using $ to find it
    $('.modal-state').prop('checked', false)

  window.assertAlertPresent = (confirm) ->
    confirm = false if typeof(confirm) is "undefind"
    ok($(".showSweetAlert").length, "Alert shows up") # Sweet Alert element falls outside test container, using $ to find it

    unless confirm
      $(".sweet-alert").remove()
      $(".sweet-overlay").remove()
    sweetAlertInitialize() # put it back

`export default helperFunctions`