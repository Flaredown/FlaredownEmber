`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`

view = Ember.View.extend

  tagName: "li"
  templateName: "questioner/_select_li"
  classNameBindings: ["input.highlight:highlight:no-highlight", "input.selected:selected:not-selected", "input.hide_color:hide-color", "input.color", "input.type", "metaLabel",]

  metaLabel: Em.computed(-> @get("input.meta_label") ).property("input")

  text: Em.computed(-> if @get("input.label") then @get("input.label") else @get("input.value")).property("input")

  mouseEnter: ->
    @get("parentView").send("setHover", @get("input.value"))
    @get("parentView.jBox").setContent(@get("input.helper")).position({target: @$()}).open() if @get("input.helper")

  mouseLeave: -> @get("parentView.jBox").close() if @get("input.helper")

  click: -> @get("parentView").send("sendResponse", @get("input.value"))

`export default view`