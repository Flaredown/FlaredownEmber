`import DS from 'ember-data'`

model = DS.Model.extend
  user:       belongsTo("user")
  
  scores:     hasMany("score")
  questions:  hasMany("question")
  responses:  hasMany("response")
  catalogs:   attr()
  date:       attr("string")
  
  # questions:  attr("object")
  # responses:  attr("object")
  # treatments: attr("object")
  # catalogs:   attr("object")
  
  moment: Ember.computed ->
    moment(@get("date"))
  .property("date")
  
  unixDate: Ember.computed -> 
    @get("moment").unix()
  .property("moment")
  
  entryDate: Ember.computed -> 
    @get("moment").format("MMM-DD-YYYY")
  .property("moment")
  
  entryDateParam: Ember.computed -> 
    return "today" if moment().format("MMM-DD-YYYY") is @get("entryDate")
    @get("entryDate")
  .property("entryDate")
  
  validResponses: Ember.computed.filter("responses", (response) -> !Ember.isEmpty response.get("value"))
  responsesData: Ember.computed.map "validResponses",
    (response) -> {name: response.get("name"), value: response.get("value")}
      
  # responsesData: Ember.computed ->
  #   normalized = Ember.A([])
  #   @get("responses").forEach (response) ->
  #     switch response.get("question.kind")
  #       when "number"
  #         if response.get("value")
  #           normalized.push(response)
  #           response.set("value", parseInt(response.get("value")) )
  #       when "select"
  #         if response.get("value")
  #           normalized.push(response)
  #           response.set("value", parseInt(response.get("value")) )
  #       when "checkbox"
  #         response.set("value", 0) unless response.get("value")
  #         normalized.push(response)      
  # .property("responses.@each.value")
  
`export default model`