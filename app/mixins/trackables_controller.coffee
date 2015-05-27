`import Ember from 'ember'`
`import config from '../config/environment'`
`import ajax from 'ic-ajax'`
`import FormHandlerMixin from '../mixins/form_handler'`

mixin = Ember.Mixin.create FormHandlerMixin,
  isEntry: Ember.computed(-> @get("model.constructor.typeKey") is "entry").property("model")
  isPastEntry: Ember.computed.and("isEntry", "model.isPast")

  anyTreatments: Em.computed.or("model.treatments", "currentUser.treatments")
  treatments: Ember.computed ->
    if @get("isEntry") then @get("model.treatments") else @get("currentUser.treatments")
  .property("currentUser.treatments.@each", "model.treatments.@each")

  treatmentNames: Em.computed(-> @get("treatments").mapBy("name").uniq() ).property("treatments.@each")
  treatmentsByName: (name) -> @get("treatments").filterBy("name",name)

  inactiveTreatments: Ember.computed(->
    actives = @get("treatments").mapBy("name")
    @get("currentUser.treatments").filter (treatment) ->
      not actives.contains treatment.get("name")
  ).property("currentUser.treatments", "treatments.@each")

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
  .property("responsesData.@each.symptoms.@each", "currentUser.symptoms.@each")

  inactiveSymptoms: Ember.computed ->
    actives = @get("symptoms").mapBy("name")
    @get("currentUser.symptoms").filter (symptom) ->
      not actives.contains symptom.get("name")
  .property("currentUser.symptoms", "symptoms.@each")

  addEntryTreatment: (treatment, editing) ->
    editing ||= false
    if Em.typeOf(treatment) is "instance"
      treatment.set("quantity", null) if treatment.get("takenWithoutDose")
      treatment = treatment.getProperties("name", "quantity", "unit")
    existings = @get("model.treatments").filterBy("name",treatment.name)
    repetition = if existings then existings.length+1 else 1

    console.log treatment
    console.log "#{treatment.name}_#{treatment.quantity}_#{treatment.unit}_#{repetition}_#{@get("id")}"
    newTreatment = @store.createRecord "treatment", Ember.merge(treatment,{id: "#{treatment.name}_#{treatment.quantity}_#{treatment.unit}_#{repetition}_#{@get("id")}", active: true, editing: editing})
    @get("model.treatments").addObject newTreatment

  addEntrySymptom: (symptom) ->
    @get("catalog_definitions.symptoms").addObject(@simpleQuestionTemplate(symptom.name))
    newResponse = @store.createRecord "response", {id: "symptoms_#{symptom.name}_#{@get("id")}", value: null, name: symptom.name, catalog: "symptoms"}
    @get("responses").addObject newResponse

  addEntryCondition: (condition) ->
    @get("catalog_definitions.conditions").addObject(@simpleQuestionTemplate(condition.name))
    newResponse = @store.createRecord "response", {id: "conditions_#{condition.name}_#{@get("id")}", value: null, name: condition.name, catalog: "conditions"}
    @get("responses").addObject newResponse


  actions:

    ### TREATMENTS ###
    addTreatmentDose: (name) ->
      treatments = @treatmentsByName(name)
      treatments.forEach (treatment) -> treatment.set("editing", false)
      first = treatments.get("firstObject")

      console.log first.get("quantity"), first.get("takenWithoutDose")
      if first.get("quantity") isnt null and not first.get("takenWithoutDose") # add a dose (e.g. treatment repetition)
        @addEntryTreatment(treatments.get("firstObject"), true)
      else  # go straight to edit
        quantity_setting = @get("currentUser.settings.treatment_#{first.get("name")}_quantity") || ""
        unit_setting = @get("currentUser.settings.treatment_#{first.get("name")}_unit") || ""
        first.setProperties(quantity: quantity_setting, unit: unit_setting, editing: true, active: true)
        @propertyDidChange("treatments")

      # else # not yet activated, activate and but don't edit
        # treatments.set("firstObject.editing", true) unless treatments.get("length") > 1
        # treatments.forEach (treatment) -> treatment.set("active", true)

    removeTreatmentDose: (treatment) ->
      treatments = @get("treatments").filterBy("name",treatment.get("name"))
      if treatments.length is 1
        treatments.get("firstObject").setProperties(quantity: null, unit: null, editing: false)
        @propertyDidChange("treatments")
      else
        @get("model.treatments").removeObject(treatment)
        treatment.unloadRecord()

    toggleTreatment: (name) ->
      if @treatmentsByName(name).get("firstObject.active")
        # Clear the first treatment of dose info and deactive, kill any others
        @treatmentsByName(name).get("firstObject").setProperties(quantity: null, unit: null, editing: false, active: false)
        @treatmentsByName(name).slice(1).forEach (treatment) =>
          @get("model.treatments").removeObject(treatment)
      else
        @treatmentsByName(name).forEach (treatment) -> treatment.set("active", true)
        @treatmentsByName(name).get("firstObject").setProperties(quantity: null, unit: null)

      false

    addTreatment: (treatment) ->
      unless @get("treatments").findBy("id","#{treatment.id}")
        if @get("isPastEntry")
          @addEntryTreatment(treatment)

        else # track it!
          ajax("#{config.apiNamespace}/treatments",
            type: "POST"
            data: {name: treatment.name}
          ).then(
            (response) =>
              @addEntryTreatment(treatment) if @get("isEntry")
              unless @get("currentUser.treatments").findBy("id","#{response.treatment.id}")
                @get("currentUser.treatments").pushObject @store.createRecord "treatment", {id: response.treatment.id, name: response.treatment.name}

            @errorCallback.bind(@)
          )

    removeTreatment: (name) ->
      @send("untrack", name, "treatment")
      @treatmentsByName(name).forEach (treatment) =>
        @get("currentUser.treatments").removeObject treatment
        @get("model.treatments").removeObject(treatment) if @get("isEntry")
        treatment.unloadRecord()

    ### SYMPTOMS ###
    addSymptom: (symptom) ->
      if @get("isPastEntry")
        @addEntrySymptom(symptom)

      else # track it!
        ajax("#{config.apiNamespace}/symptoms",
          type: "POST"
          data: {name: symptom.name}
        ).then(
          (response) =>
            @addEntrySymptom(symptom) if @get("isEntry")
            unless @get("currentUser.symptoms").findBy("id","#{response.symptom.id}")
              @get("currentUser.symptoms").pushObject @store.createRecord "symptom", {id: response.symptom.id, name: response.symptom.name}

          @errorCallback.bind(@)
        )

    removeSymptom: (symptom) ->
      @send("untrack", symptom.name, "symptom")
      @get("catalog_definitions.symptoms").forEach (section,i) =>
        if section[0].name is symptom.name
          @get("catalog_definitions.symptoms").removeAt(i)

      # TODO Beware during Questioner Refactor! Removal of catalog_definitions.symptoms above doesn't trigger
      # update of responsesData, removeResponse below does though so it's okay for now.
      @send("removeResponse", symptom.name)


    ### CONDITIONS ###
    addCondition: (condition) ->
      if @get("isPastEntry")
        @addEntryCondition(condition)

      else # track it!
        ajax("#{config.apiNamespace}/conditions",
          type: "POST"
          data: {name: condition.name}
        ).then(
          (response) =>
            @addEntryCondition(condition) if @get("isEntry")
            unless @get("currentUser.conditions").findBy("id","#{response.condition.id}")
              @get("currentUser.conditions").pushObject @store.createRecord "condition", {id: response.condition.id, name: response.condition.name}

          @errorCallback.bind(@)
        )

    removeCondition: (condition) ->
      @send("untrack", condition.name, "condition")
      @get("catalog_definitions.conditions").forEach (section,i) =>
        if section[0].name is condition.name
          @get("catalog_definitions.conditions").removeAt(i)

      @send("removeResponse", condition.name)

    untrack: (name, type) ->
      plural = "#{type}s"
      model = @get("currentUser.#{plural}").findBy("name", name)
      id = model.get("id") if model # possible it's already been untracked
      if id and not @get("isPast")
        ajax("#{config.apiNamespace}/#{plural}/#{id}", type: "DELETE").then(
          => null
          @errorCallback.bind(@)
        )

    # track: (name, type) ->
    #   plural = "#{type}s"
    #   unless @get("isPast")
    #     ajax("#{config.apiNamespace}/#{plural}/#{name}", type: "POST").then(
    #       => null
    #       @errorCallback.bind(@)
    #     )

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