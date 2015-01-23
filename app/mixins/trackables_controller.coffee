`import Ember from 'ember'`

mixin = Ember.Mixin.create

  inactiveTreatments: Ember.computed(->
    actives = @get("treatments").mapBy("name")
    @get("currentUser.treatments").filter (treatment) ->
      not actives.contains treatment.get("name")
  ).property("currentUser.treatments", "treatments.@each")


  symptoms: Ember.computed ->
    @get("responsesData").filterBy("catalog", "symptoms")
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
      newTreatment = @store.createRecord "treatment", Ember.merge(treatment,{id: "#{treatment.name}_#{treatment.quantity}_#{treatment.unit}_#{@get("id")}"})
      @get("treatments").addObject newTreatment

    removeTreatment: (treatment) ->
      @get("treatments").removeObject treatment
      treatment.unloadRecord()

    ### SYMPTOMS ###
    addSymptom: (symptom) ->
      @get("catalog_definitions.symptoms").addObject(@symptomDefinitionTemplate(symptom.name))

    removeSymptom: (symptom) ->
      @get("catalog_definitions.symptoms").forEach (section,i) =>
        if section[0].name is symptom.get("name")
          @get("catalog_definitions.symptoms").removeAt(i)

  symptomDefinitionTemplate: (name) ->
    [{
      name: name,
      kind: "select"
      inputs: [
        {value: 0, helper: null, label: "",meta_label: ""}
        {value: 1, helper: null, label: "",meta_label: ""}
        {value: 2, helper: null, label: "",meta_label: ""}
        {value: 3, helper: null, label: "",meta_label: ""}
        {value: 4, helper: null, label: "",meta_label: ""}
      ]
    }]


`export default mixin`