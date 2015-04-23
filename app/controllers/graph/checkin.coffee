`import Ember from 'ember'`
`import config from '../../config/environment'`
`import TrackablesControllerMixin from '../../mixins/trackables_controller'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`
`import FormHandlerMixin from '../../mixins/form_handler'`
`import ajax from 'ic-ajax'`

controller = Ember.ObjectController.extend TrackablesControllerMixin, GroovyResponseHandlerMixin, FormHandlerMixin, Em.I18n.TranslateableProperties,

  saveOnSectionChange: true
  modalOpen: true
  sectionsSeen: []

  yesterdayDate: Em.computed(-> moment(@get("moment")).subtract(1,"day").format("MMM-DD-YYYY") ).property("moment")
  tomorrowDate: Em.computed(-> moment(@get("moment")).add(1,"day").format("MMM-DD-YYYY") ).property("moment")

  nonResearchSections: ["start", "conditions", "treatments", "symptoms", "treatments-empty", "conditions-empty", "notes", "finish"]
  userQuestionSections: ["conditions","symptoms"]
  defaultResponseValues:
    checkbox: 0
    select: null
    number: null

  needs: ["graph"]

  # Watch some user actions
  modalChanged: Ember.observer ->
    unless @get("modalOpen")
      @send("save") if @saveForm()
      @set("sectionsSeen", [])
      @transitionToRoute("graph")
      @set("modalOpen", true)
  .observes("modalOpen")

  sectionChanged: Ember.observer ->
    if @get("section")
      @get("sectionsSeen").addObject @get("section") # Set seen sections
      @transitionToRoute("graph.checkin", @get("dateAsParam"), @get("section"))

  .observes("section")

  checkinComplete: Ember.computed( ->
    return false if @get("responsesData").filterBy("value", null).length
    true
  ).property("responsesData")

  catalogsSorted: Ember.computed(->
    catalogs = @get("catalogs")
    catalogs.removeObjects(["symptoms", "conditions"])
    catalogs.sort()
    catalogs.addObjects(["symptoms", "conditions"])
  ).property("catalogs")

  responsesData: Ember.computed ->
    that            = @
    responses       = []

    @get("catalogsSorted").forEach (catalog) =>
      @get("catalog_definitions.#{catalog}").forEach (section) =>
        section.forEach (question) ->
          # Lookup an existing response loaded on the Entry, use it's value to setup responsesData, otherwise null
          response  = that.get("responses").findBy("id", "#{catalog}_#{question.name}_#{that.get("model.id")}")
          value     = if response then response.get("value") else that.defaultResponseValues[question.kind]

          responses.pushObject Ember.Object.create({name: question.name, value: value, catalog: catalog})

    responses
  .property("catalog_definitions")

  ### Sections: All the pages in the checkin form ###
  sectionsDefinition: Ember.computed ->
    _definition = if @get("just_created") then [["start",1]] else []
    @get("catalogsSorted").forEach (catalog) =>
      length = @get("catalog_definitions.#{catalog}.length")
      _definition.push [catalog,length] unless length is 0 or @get("userQuestionSections").contains(catalog)

    ["conditions", "symptoms", "treatments", "notes", "finish"].forEach (section) -> _definition.push [section, 1]

    _definition
  .property("catalogsSorted", "catalog_definitions", "catalog_definitions.symptoms.@each")

  sections: Ember.computed ->
    _sections = []

    @get("sectionsDefinition").forEach (section,i) =>
      [name,size] = section
      number      = i+1

      [0..size-1].forEach (subsection_index) =>
        if subsection_index >= 0
          subsection    = _sections.length+1
          research      = not @get("nonResearchSections").contains(name)
          completable   = research or @get("userQuestionSections").contains(name)
          is_selected   = (subsection is @get("section"))
          is_seen       = @isSeen(subsection)
          is_complete   = (is_seen and not completable) or (completable and @hasCompleteResponse(name,subsection_index))

          _sections.addObject {
            number:           subsection
            selected:         is_selected
            category_number:  subsection_index+1
            category:         name
            research:         research
            seen:             is_seen
            complete:         is_seen and is_complete
            skipped:          is_seen and not is_complete # and not is_selected -- still skipped even if selected
          }

    _sections

  .property("sectionsDefinition", "catalogs", "section", "responsesData.@each.value")

  ### Section Helpers ###
  isSeen: (section) ->
    return true unless @get("just_created") is true
    @get("sectionsSeen").contains(section)

  hasCompleteResponse: (catalog,section_index) ->
      questions = []
      if @get("userQuestionSections").contains(catalog)
        questions = @get("catalog_definitions.#{catalog}").mapBy("firstObject")
      else
        questions = @get("catalog_definitions.#{catalog}")[section_index]

      not questions.map((question) =>
        return true if question.kind is "checkbox"

        response = @get("responsesData").filterBy("catalog", catalog).findBy("name", question.name)
        return false unless response
        response.get("value") isnt null
      ).contains(false)

  currentSection:             Ember.computed( -> @get("sections").objectAt(@get("section")-1) ).property("section", "sections.@each")
  isFirstSection:             Ember.computed( -> @get("sections.firstObject.number") is @get("section") ).property("section", "sections.@each")
  isLastSection:              Ember.computed( -> @get("sections.lastObject.number") is @get("section") ).property("section", "sections.@each")

  sectionHeader:              Ember.computed( -> Em.I18n.t("#{@get("sections.name")}_#{@get("sections.number")}_header") ).property("section", "sections.@each")

  questionSections:           Ember.computed.filterBy("sections", "question")
  completedQuestionSections:  Ember.computed.filterBy("questionSections", "complete")

  categories:                 Ember.computed( -> @get("sections").mapProperty("category").uniq()                ).property("sections")
  currentCategory:            Ember.computed( -> @get("currentSection.category")                                ).property("currentSection")
  currentCategorySections:    Ember.computed( -> @get("sections").filterBy("category", @get("currentCategory")) ).property("currentCategory")

  isSymptomCategory:          Ember.computed.equal("currentCategory", "symptoms")

  currentPartial:             Ember.computed( ->
    return "questioner/#{@get("currentCategory")}" if @get("nonResearchSections").contains(@get("currentCategory"))
    "questioner/questions"
  ).property("currentCategory")

  ### Translation keys ###
  catalogStub:          Ember.computed( -> "catalogs.#{@get("currentCategory")}" ).property("currentCategory")
  currentSectionPrompt: Ember.computed( ->
    if @get("currentSection.category") is "symptoms"
      Ember.I18n.t "symptom_question_prompt", name: @get("sectionQuestions.firstObject.name").capitalize()
    else if @get("currentSection.category") is "conditions"
      Ember.I18n.t "conditions_question_prompt", name: @get("sectionQuestions.firstObject.name").capitalize()
    else
      Ember.I18n.t "#{@get("catalogStub")}.section_#{@get("currentSection.category_number")}_prompt"
  ).property("currentSection")

  sectionQuestions: Ember.computed ->
    section = @get("currentSection")

    return [] unless @get("catalog_definitions") and @get("catalogs").contains(section.category)
    catalog_questions = @get("catalog_definitions.#{section.category}")
    if @get("userQuestionSections").contains(section.category)
      catalog_questions.map (section) -> section[0]
    else
      catalog_questions[ section.category_number-1 ]

  .property("section.category", "currentSection", "catalog_definitions.conditions.@each", "catalog_definitions.symptoms.@each", "catalog_definitions.treatments.@each")

  sectionResponses: Ember.computed( -> @get("responsesData").filterBy("catalog", @get("currentCategory")) ).property("currentCategory", "responsesData.@each")

  actions:
    closeCheckin: -> @set("modalOpen", false)

    setResponse: (question_name, value) ->
      id = "#{@get("currentCategory")}_#{question_name}_#{@get("model.id")}"
      response = @get("responses").findBy("id", id)

      if Ember.isPresent(response) and value isnt null
        response.set("value", value)
      else
        newResponse = @store.createRecord "response", {id: id, value: value, name: question_name, catalog: @get("currentCategory")}
        @get("responses").addObject newResponse

      @propertyDidChange("responsesData")
      @send("nextSection") if @get("sectionQuestions.length") is 1

    setSection: (section) ->
      if @saveForm()
        @send("save") if @get("saveOnSectionChange")
        @set("section", section) if @get("sections").mapBy("number").contains(section)

    nextSection:     -> @send("setSection",(@get("section")+1)) unless @get("section") is @get("sections.lastObject.number")
    previousSection: -> @send("setSection",(@get("section")-1)) unless @get("section") is @get("sections.firstObject.number")

    save: (close) ->


      checkin_data =
        responses: @get("responsesData")
        notes: @get("notes")

      treatment_data = @get("treatments").map((treatment) -> treatment.getProperties("name", "quantity", "unit") if treatment.get("active")).compact() if @get("treatments")
      checkin_data["treatments"] = treatment_data if Em.isPresent(treatment_data)

      data =
        entry:
          JSON.stringify(checkin_data)

      unless @get("lastSave.entry") is data.entry # don't bother saving unless there are changes
        ajax(
          url: "#{config.apiNamespace}/entries/#{@get('date')}.json"
          type: "PUT"
          data: data
        ).then(
          (response) =>
            @set("lastSave", data)
            @set("modalOpen", false) if close
            # if @get("checkinComplete") # only process the entry if it's complete
            # TODO unfilled question datums
            # TODO reenable when putting graph back in
            # @get("controllers.graph").send("dayProcessing", @get("date"))
          (response) => @errorCallback(response)
        )

`export default controller`