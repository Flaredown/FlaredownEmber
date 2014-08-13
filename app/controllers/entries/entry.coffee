`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  titleBinding: "id"
  
  sectionChanged: Ember.observer ->
    @transitionToRoute("entries.entry", @get("entryDateParam"), @get("section")) if @get("section")
  .observes("section")
  
  sections: Ember.computed ->
    self = @
    @get("questions").mapBy("section").uniq().sort().map (section) -> 
      {number: section, selected: section is self.get("section")}
  .property("questions.section", "section")
  
  sectionResponses: Ember.computed ->
    names = @get("questions").filterBy("section", @get("section")).mapBy("name")
    @get("responses").filter (response) -> names.contains(response.get("name"))
  .property("questions.section", "section", "responses.@each")
  
  actions:
    setResponse: (response, value) -> 
      response.set("value", parseInt(value))
      @send("nextSection") if @get("sectionResponses.length") == 1
      @send("save")
    
    setSection: (section) -> 
      @set("section", section) if @get("sections").mapBy("number").contains(section)
    nextSection: -> 
      @set("section", @get("section")+1) unless @get("section") is @get("sections.lastObject.number")
    previousSection: -> 
      @set("section", @get("section")-1) unless @get("section") is @get("sections.firstObject.number")
      
    save: ->
      that = @
      
      data = 
        entry:
            JSON.stringify({responses: @get("responsesData")})
      
      $.ajax
        url: "#{FlaredownENV.apiNamespace}/entries/#{@get('id')}.json"
        type: "PUT"
        data: data
        success: (response) -> 
          null
        error: (response) ->
          console.log "response error !!!"

`export default controller`