`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`

mixin = Ember.Mixin.create

  inactiveTreatments: Ember.computed(->
    actives = @get("treatments").mapBy("name")
    @get("currentUser.treatments").filter (treatment) ->
      not actives.contains treatment.get("name")
  ).property("currentUser.treatments", "treatments.@each")

  symptoms: Ember.computed ->
    @get("responsesData").filterBy("catalog", "symptoms")
  .property("responsesData.@each.symptoms.@each")

  conditions: Ember.computed ->
    @get("responsesData").filterBy("catalog", "conditions")
  .property("responsesData.@each.conditions.@each")

  inactiveSymptoms: Ember.computed ->
    actives = @get("symptoms").mapBy("name")
    @get("currentUser.symptoms").filter (symptom) ->
      not actives.contains symptom.get("name")
  .property("currentUser.symptoms", "symptoms.@each")

  actions:
    ### TREATMENTS ###
    treatmentEdited: -> @get("treatments").forEach (treatment) -> treatment.set("quantity", parseFloat(treatment.get("quantity")))
    addTreatment: (treatment) ->
      ajax("#{config.apiNamespace}/treatments",
        type: "POST"
        data: {name: treatment.name}
      ).then(
        (response) =>
          newTreatment = @store.createRecord "treatment", Ember.merge(treatment,{id: "#{treatment.name}_#{treatment.quantity}_#{treatment.unit}_#{@get("id")}"})
          @get("treatments").addObject newTreatment

        (response) => @errorCallback(response, @)
      )

    removeTreatment: (treatment) ->
      @get("treatments").removeObject treatment
      treatment.unloadRecord()

    ### SYMPTOMS ###
    addSymptom: (symptom) ->
      ajax("#{config.apiNamespace}/symptoms",
        type: "POST"
        data: {name: symptom.name}
      ).then(
        (response) =>
          @get("catalog_definitions.symptoms").addObject(@simpleQuestionTemplate(symptom.name))
          newResponse = @store.createRecord "response", {id: "symptoms_#{symptom.name}_#{@get("id")}", value: null, name: symptom.name, catalog: "symptoms"}
          @get("responses").addObject newResponse

        (response) => @errorCallback(response, @)
      )

    removeSymptom: (symptom) ->
      @get("catalog_definitions.symptoms").forEach (section,i) =>
        if section[0].name is symptom.name
          @get("catalog_definitions.symptoms").removeAt(i)

    ### CONDITIONS ###
    addCondition: (condition) ->
      ajax("#{config.apiNamespace}/conditions",
        type: "POST"
        data: {name: condition.name}
      ).then(
        (response) =>
          @get("catalog_definitions.conditions").addObject(@simpleQuestionTemplate(condition.name))
          newResponse = @store.createRecord "response", {id: "conditions_#{condition.name}_#{@get("id")}", value: null, name: condition.name, catalog: "conditions"}
          @get("responses").addObject newResponse
        (response) => @errorCallback(response, @)
      )

    removeCondition: (condition) ->
      @get("catalog_definitions.conditions").forEach (section,i) =>
        if section[0].name is condition.name
          @get("catalog_definitions.conditions").removeAt(i)

  simpleQuestionTemplate: (name) ->
    [{
      name: name,
      kind: "select"
      inputs: [
        {value: 0, helper: "basic_0", meta_label: "smiley"}
        {value: 1, helper: "basic_1", meta_label: ""}
        {value: 2, helper: "basic_2", meta_label: ""}
        {value: 3, helper: "basic_3", meta_label: ""}
        {value: 4, helper: "basic_4", meta_label: ""}
      ]
    }]


`export default mixin`