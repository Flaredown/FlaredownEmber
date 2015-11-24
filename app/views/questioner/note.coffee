`import Ember from 'ember'`
`import TaggableNotesMixin from '../../mixins/taggable_notes'`

view = Ember.View.extend # TaggableNotesMixin,

  tagName: "textarea"
  templateName: "questioner/note-textarea"
  classNames: ["checkin-note-textarea", "summary-note"]

  # Variables:
  editable: true

  contenteditable: (->
    editable = @get("editable")
    (if editable then "true" else `undefined`)
  ).property("editable")

  spellcheck: true
  role: "textbox"
  "aria-multiline": true

  attributeBindings: ["contenteditable", "spellcheck", "role", "aria-multiline"]

  # Placeholder
  placeholder: "Leave a note about your day"
  isPlaceheld: Ember.computed(->
    return false if (@$().val() || '').length > 0
    return true
  ).property()
  .volatile()
  setPlaceholder: -> @$().attr("placeholder", @placeholder) if Ember.isEmpty(@$().text())

  didInsertElement: ->
    @set "value", @get("controller.notes")
    @$().html(@get("value"))
    @setPlaceholder()

    @$().on("paste", @paste.bind(@))
    Ember.run.next => @$().focus() unless @get("isPlaceheld")

  # Only on modal close instead
  willDestroyElement: ->
    @set "value", @get("controller.notes")
    @get("controller").send("save")

  textAdded: ->
    @get("controller").set("notes", @$().text())
    @set "controller.notesSaved", false

  paste: (event) ->
    event.preventDefault()
    text = event.originalEvent.clipboardData.getData("text")
    document.execCommand('insertText', false, text)
    @textAdded()

  focusIn: -> @$().text("") if @get("isPlaceheld")

  keyUp:    (event) ->
    switch event.keyCode
      when 27 # keyboard: escape
        @get("controller").set("modalOpen", false)
      else
        @textAdded()

`export default view`