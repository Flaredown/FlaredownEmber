`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import FormHandlerMixin from '../mixins/form_handler'`


mixin = Ember.Mixin.create FormHandlerMixin,
  isEntry: Ember.computed(-> @get("model.constructor.typeKey") is "entry").property("model")

  treatments: Ember.computed ->
    if @get("isEntry") then @get("model.treatments") else @get("currentUser.treatments")
  .property("currentUser.treatments.@each", "model.treatments.@each")

  # inactiveTreatments: Ember.computed(->
  #   actives = @get("treatments").mapBy("name")
  #   @get("currentUser.treatments").filter (treatment) ->
  #     not actives.contains treatment.get("name")
  # ).property("currentUser.treatments", "treatments.@each")

  conditions: Ember.computed ->
    if @get("responsesData")
      @get("responsesData").filterBy("catalog", "conditions")
    else
      @get("currentUser.conditions")
  .property("responsesData.@each.conditions.@each", "currentUser.conditions.@each")

  inactiveConditions: Ember.computed ->
    actives = @get("conditions").mapBy("name")
    @get("currentUser.conditions").filter (condition) ->
      not actives.contains condition.get("name")
  .property("currentUser.conditions", "conditions.@each")

  symptoms: Ember.computed ->
    if @get("responsesData")
      @get("responsesData").filterBy("catalog", "symptoms")
    else
      @get("currentUser.symptoms")
  .property("responsesData.@each.symptoms.@each")

  inactiveSymptoms: Ember.computed ->
    actives = @get("symptoms").mapBy("name")
    @get("currentUser.symptoms").filter (symptom) ->
      not actives.contains symptom.get("name")
  .property("currentUser.symptoms", "symptoms.@each")

  actions:
    ### TREATMENTS ###
    treatmentEdited: -> @get("treatments").forEach (treatment) -> treatment.set("quantity", parseFloat(treatment.get("quantity")))
    addTreatment: (treatment) ->
      unless @get("treatments").findBy("id","#{treatment.id}")
        ajax("#{config.apiNamespace}/treatments",
          type: "POST"
          data: {name: treatment.name}
        ).then(
          (response) =>
            if @get("isEntry")
              newTreatment = @store.createRecord "treatment", Ember.merge(treatment,{id: "#{treatment.name}_#{treatment.quantity}_#{treatment.unit}_#{@get("id")}"})
              newTreatment.set("active", true)
              @get("model.treatments").addObject newTreatment

            unless @get("currentUser.treatments").findBy("id","#{response.treatment.id}")
              @get("currentUser.treatments").pushObject @store.createRecord "treatment", {id: response.treatment.id, name: response.treatment.name}

          @errorCallback
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
          if @get("isEntry")
            @get("catalog_definitions.symptoms").addObject(@simpleQuestionTemplate(symptom.name))
            newResponse = @store.createRecord "response", {id: "symptoms_#{symptom.name}_#{@get("id")}", value: null, name: symptom.name, catalog: "symptoms"}
            @get("responses").addObject newResponse

          @get("currentUser.symptoms").pushObject @store.createRecord "symptom", {id: response.symptom.id, name: response.symptom.name}

        @errorCallback
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
          if @get("isEntry")
            @get("catalog_definitions.conditions").addObject(@simpleQuestionTemplate(condition.name))
            newResponse = @store.createRecord "response", {id: "conditions_#{condition.name}_#{@get("id")}", value: null, name: condition.name, catalog: "conditions"}
            @get("responses").addObject newResponse

          @get("currentUser.conditions").pushObject @store.createRecord "condition", {id: response.condition.id, name: response.condition.name}

        @errorCallback
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