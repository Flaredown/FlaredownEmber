helperFunctions = ->
  window.clickOn = (elem) ->
    $(elem).simulate("click")

  window.assertModalPresent = ->
    ok($(".modal").length, "Modal shows up") # Sweet Alert element falls outside test container, using $ to find it
    $('.modal-state').prop('checked', false)

  window.assertAlertPresent = ->
    ok($(".showSweetAlert").length, "Alert shows up") # Sweet Alert element falls outside test container, using $ to find it

    # get rid of this stuff
    $(".sweet-alert").remove()
    $(".sweet-overlay").remove()
    sweetAlertInitialize() # put it back

`export default helperFunctions`