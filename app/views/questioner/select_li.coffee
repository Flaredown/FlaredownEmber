`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`

view = Ember.View.extend

  tagName: "li"
  templateName: "questioner/_select_li"
  classNameBindings: ["input.color", "input.highlight:highlight", "input.selected:selected", "metaLabel"]

  metaLabel: Em.computed(-> @get("input.meta_label") ).property("input")

  text: Em.computed(-> if @get("input.label") then @get("input.label") else @get("input.value")).property("input")

  didInsertElement: ->
    if @get("input.helper")
      @$().jBox("Tooltip", {id: "jbox-tooltip", x: "center", y: "center", content: @get("input.helper") })
  mouseEnter: -> @get("parentView").send("setHover", @get("input.value"))
  mouseLeave: -> @get("parentView").send("setHover", null)
  click: ->      @get("parentView").send("sendResponse", @get("input.value"))

`export default view`