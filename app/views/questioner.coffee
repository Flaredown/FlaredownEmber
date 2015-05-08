`import Ember from 'ember'`

view = Ember.View.extend
  templateName: "questioner"
  classNames: ["questioner"]

  entryBinding:   "controller"

  setFocus: (->
    if @$()
      @$().attr({ tabindex: 1 })
      @$().focus()
  ).on('didInsertElement')

  sectionChanged: Ember.observer ->
    @set("entry.section", 1) if @get("entry.sections") and not @get("entry.sections").mapBy("number").contains @get("entry.section")

    Ember.run =>
      @setFocus()
      @$("input").attr("tabindex", "1") if @$("input")
      @$("button[type=submit]").attr("tabindex", "2") if @$("button[type=submit]")

    Ember.run.next =>
      @get("removeTooltip").attach($(".remove-trackable")) if @get("removeTooltip")

  .observes("entry.section").on("init")

  didInsertElement: ->
    unless @get("controller.isPast")
      @set "removeTooltip", new jBox("Tooltip", {
      # $(".remove-trackable").jBox("Tooltip", {
        id: "remove-trackable-tooltip"
        content: Ember.I18n.t("trackable_remove_tooltip")
        offset: {x:0, y:-40}
        addClass: "remove-trackable-tooltip"
        x: "center"
        y: "center"
        ignoreDelay: true
        fade: false
      })
      @get("removeTooltip").attach($(".remove-trackable"))
  willDestroyElement: -> @get("removeTooltip").destroy() if @get("removeTooltip")

  keyDown: (e) ->
    active = $(document.activeElement)
    unless active.is("input") or active.hasClass("checkin-note-textarea")
      switch e.keyCode
        when 48 then @get("entry").send("setSection", 10)   # keyboard: 0
        when 49 then @get("entry").send("setSection", 1)    # keyboard: 1
        when 50 then @get("entry").send("setSection", 2)    # keyboard: 2
        when 51 then @get("entry").send("setSection", 3)    # keyboard: 3
        when 52 then @get("entry").send("setSection", 4)    # keyboard: 4
        when 53 then @get("entry").send("setSection", 5)    # keyboard: 5
        when 54 then @get("entry").send("setSection", 6)    # keyboard: 6
        when 55 then @get("entry").send("setSection", 7)    # keyboard: 7
        when 56 then @get("entry").send("setSection", 8)    # keyboard: 8
        when 57 then @get("entry").send("setSection", 9)    # keyboard: 9
        when 37 then @get("entry").send("previousSection")  # keyboard: left arrow
        when 39 then @get("entry").send("nextSection")      # keyboard: right arrow
        # TODO reenable for Graph Release (use key responder thing)
        # when 27 then @get("entry").set("modalOpen", false)  # keyboard: escape

`export default view`