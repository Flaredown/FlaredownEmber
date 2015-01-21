`import Ember from 'ember'`

view = Ember.View.extend
  templateName: "edit-checkin"
  entryBinding:   "controller"

  setFocus: (->
    if @$()
      @$().attr({ tabindex: 1 })
      @$().focus()
  ).on('didInsertElement')

  keyDown: (e) ->
    switch e.keyCode
      when 27 then @get("entry").set("modalOpen", false)  # keyboard: escape

`export default view`