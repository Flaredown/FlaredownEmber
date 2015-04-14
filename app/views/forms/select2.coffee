`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "input"

  config: Ember.computed( ->
    {
      data: @get("content")
      placeholder: @get("placeholder")
      val: @get("value")
      multiple: @get("multiple")
      initSelection: ((el,callback) ->
        initialValue = @get("content").findBy("text",@get("value"))
        callback(initialValue) if initialValue
      ).bind(@)
    }
  ).property("content")

  opened: (event) ->
  selected: (event) ->
    choice = event.choice.text
    if @get("multiple")
      @get("value").addObject(choice)
    else
      @set("value", choice)

  removed: (event) ->
    choice = event.choice.text
    @get("value").removeObject(choice) if @get("multiple")


  didInsertElement: ->
    Ember.run.scheduleOnce('afterRender', @, 'processChildElements')
    @$().on("select2-selecting", @selected.bind(@))
    @$().on("select2-removing", @removed.bind(@))
    @$().on("select2-open", @opened.bind(@))
    @set("value", []) if not @get("value") and @get("multiple") is true

  processChildElements: -> @$().select2(@get("config")).select2("val", @get("value"))
  willDestroyElement: -> @$().select2("destroy")

`export default view`