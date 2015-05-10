`import Ember from 'ember'`

view = Ember.View.extend

  init: ->
    @_super()

    # Watch the "name" field on the parent "controller"
    Em.defineProperty @, "errors", Em.computed( ->
      @get("controller.errors.fields.#{@get("parent.name")}")
    ).property("controller.errors.fields.#{@get("parent.name")}")

  tagName: "input"
  allowCustom: false
  open: false

  config: Ember.computed( ->
    _config = {
      data: @get("content")
      placeholder: @get("placeholder")
      val: @get("value")
      multiple: @get("multiple")
      formatResult: @get("formatted").bind(@)
      initSelection: ((el,callback) ->
        initialValue = if @get("multiple")
            @get("content").map( (option,i) => option if @get("value").contains(option.text) ).compact()
          else
            selection = @get("content").findBy("text",@get("value"))
            if selection
              selection
            else if @get("allowCustom")
              {id: 0, text: @get("value")}
        callback(initialValue) if initialValue
      ).bind(@)
    }
    _config.createSearchChoice = ((term) -> {id: 0, text: term} unless @get("content").mapBy("text").contains(term) ).bind(@) if @get("allowCustom")
    _config

  ).property("content")

  formatted: (option) ->
    if @get("descriptions")
      "<span class='name'>#{option.text}</span><div class='description'>#{option.description}</div>"
    else
      "<span class='name'>#{option.text}</span>"

  focused: (event) ->
    select2 = @$().data("select2")
    Ember.run.later => select2.open() unless @get("open")

  opened: (event) ->
    Ember.run.later(
      => @set("open", true)
      ,
      200
    )

  closed: (event) -> @set("open", false)

  selected: (event) ->
    if @get("open")
      choice = event.choice.text
      if @get("multiple")
        @get("value").addObject(choice)
      else
        @set("value", choice)
    else
      false

  removed: (event) ->
    choice = event.choice.text
    @get("value").removeObject(choice) if @get("multiple")


  didInsertElement: ->
    Ember.run.scheduleOnce('afterRender', @, 'processChildElements')
    @$().on("select2-selecting", @selected.bind(@))
    @$().on("select2-removing", @removed.bind(@))
    @$().on("select2-opening", @opened.bind(@))
    @$().on("select2-opening", @closed.bind(@))
    @$().on("select2-focus", @focused.bind(@))
    @set("value", []) if not @get("value") and @get("multiple") is true

  processChildElements: -> @$().select2(@get("config")).select2("val", @get("value")) unless @get("isDestroyed") or @get("isDestroying")
  willDestroyElement: -> @$().select2("destroy")

`export default view`