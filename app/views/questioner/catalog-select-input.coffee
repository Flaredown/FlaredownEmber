`import Ember from 'ember'`
`import colorableMixin from '../../mixins/colorable'`

view = Ember.View.extend

  tagName: "li"
  templateName: "questioner/_select_li"
  classNameBindings: ["input.selected:selected", "input.type", "metaLabel"]

  metaLabel: Em.computed(-> @get("input.meta_label") ).property("input")

  text: Em.computed(-> if @get("input.label") then @get("input.label") else @get("input.value")).property("input")

  tap: ->       @get("parentView").send("sendResponse", @get("input.value"))

`export default view`