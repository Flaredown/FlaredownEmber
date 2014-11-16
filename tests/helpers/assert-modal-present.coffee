assertModalPresent = ->
    ok($(".modal").length, "Modal shows up") # Sweet Alert element falls outside test container, using $ to find it
    $('.modal-state').prop('checked', false);
`export default assertModalPresent`