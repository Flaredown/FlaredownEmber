assertAlertPresent = ->
    ok($(".showSweetAlert").length, "Alert shows up") # Sweet Alert element falls outside test container, using $ to find it

    # get rid of this stuff
    # TODO this will break with 2 alerts in a single test
    $(".sweet-alert").remove()
    $(".sweet-overlay").remove()

`export default assertAlertPresent`