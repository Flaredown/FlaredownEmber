assertAlertPresent = ->
    ok($(".showSweetAlert").length, "Alert shows up") # Sweet Alert element falls outside test container, using $ to find it

    # get rid of this stuff
    $(".sweet-alert").remove()
    $(".sweet-overlay").remove()
    sweetAlertInitialize() # put it back

`export default assertAlertPresent`