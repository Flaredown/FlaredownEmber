`import Ember from 'ember'`

view = Ember.View.extend
  templateName: "modal"
  
  tagName: "div"
  classNames: "modal fade in".w()
  
  attributeBindings: "tabindex role ariaLabelledby".w()
  role: "dialog"
  ariaLabelledby: Ember.computed(-> @get("controller.title")).property("controller.title")
    
  didInsertElement: ->
    @$().modal "show"
    @$().bind "hide.bs.modal", $.proxy( (-> @get("controller").transitionToRoute("entries.index")), @)
    
  willDestroyElement: ->
    @$().unbind "hide.bs.modal"
    @$().modal "hide"
    
`export default view`