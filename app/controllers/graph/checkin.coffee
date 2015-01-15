`import Ember from 'ember'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`

controller = Ember.ObjectController.extend
  modalOpen: true
  sectionsSeen: []

  defaultResponseValues:
    checkbox: 0
    select: null
    number: null

  needs: ["graph"]

  # Watch some user actions
  modalChanged: Ember.observer ->
    unless @get("modalOpen")
      @send("save")
      @transitionToRoute("graph")
      @set("modalOpen", true)
  .observes("modalOpen")

  sectionChanged: Ember.observer ->
    if @get("section")
      @get("sectionsSeen").addObject @get("section")
      @transitionToRoute("graph.checkin", @get("dateAsParam"), @get("section"))
  .observes("section")

  checkinComplete: Ember.computed( ->
    return false if @get("responsesData").filterBy("value", null).length
    true
  ).property("responsesData")

  catalogsSorted: Ember.computed(->
    catalogs = @get("catalogs")
    catalogs.removeObject("symptoms")
    catalogs.sort()
    catalogs.addObject("symptoms")
  ).property("catalogs")

  ### Sections: All the pages in the checkin form ###
  sectionsDefinition: Ember.computed ->
    _definition = [["start",1]]
    @get("catalogsSorted").forEach (catalog) => _definition.push [catalog,@get("catalog_definitions.#{catalog}.length")]
    ["treatments", "notes", "finish"].forEach (section) -> _definition.push [section, 1]
    _definition
  .property("catalogsSorted")

  sections: Ember.computed ->
    _sections = []

    @get("sectionsDefinition").forEach (section,i) =>
      [name,size] = section
      number      = i+1

      [0..size-1].forEach (subsection_index) =>
        subsection    = _sections.length+1
        question      = not ["start", "treatments", "notes", "finish"].contains(name)
        is_selected   = (subsection is @get("section"))
        is_seen       = @isSeen(subsection)
        is_complete   = not question or @hasCompleteResponse(name,subsection_index)

        _sections.addObject {
          number:           subsection
          selected:         is_selected
          category_number:  subsection_index+1
          category:         name
          question:         question
          seen:             is_seen
          complete:         is_seen and is_complete
          skipped:          is_seen and not is_complete and not is_selected
        }

    _sections

  .property("sectionsDefinition", "catalogs", "section", "responsesData")

  ### Section Helpers ###
  isSeen: (section) -> @get("sectionsSeen").contains(section)
  hasCompleteResponse: (catalog,section_index) ->
      section = @get("catalog_definitions.#{catalog}")[section_index]
      return true if section.kind is "checkbox"

      not section.map((question) =>
        response = @get("responsesData").filterBy("catalog", catalog).findBy("name", question.name)
        return false unless response
        response.get("value") isnt null
      ).contains(false)

  currentSection:             Ember.computed( -> @get("sections").objectAt(@get("section")-1) ).property("section", "sections.@each")
  isFirstSection:             Ember.computed( -> @get("sections.firstObject.number") is @get("section") ).property("section", "sections.@each")
  isLastSection:              Ember.computed( -> @get("sections.lastObject.number") is @get("section") ).property("section", "sections.@each")

  questionSections:           Ember.computed.filterBy("sections", "question")
  completedQuestionSections:  Ember.computed.filterBy("questionSections", "complete")

  categories:                 Ember.computed( -> @get("sections").mapProperty("category").uniq()                ).property("sections")
  currentCategory:            Ember.computed( -> @get("currentSection.category")                                ).property("currentSection")
  currentCategorySections:    Ember.computed( -> @get("sections").filterBy("category", @get("currentCategory")) ).property("currentCategory")

  currentPartial:             Ember.computed( ->
    return "questioner/#{@get("currentCategory")}" if ["start", "treatments", "notes", "finish"].contains(@get("currentCategory"))
    "questioner/questions"
  ).property("currentCategory")

  ### Translation keys ###
  catalogStub:          Ember.computed( -> "#{@get("currentUser.locale")}.catalogs.#{@get("currentCategory")}" ).property("currentCategory")
  currentSectionPrompt: Ember.computed( ->
    if @get("currentSection.category") is "symptoms"
      Ember.I18n.t "#{@get("currentUser.locale")}.symptom_question_prompt", name: @get("sectionQuestions.firstObject.name").capitalize()
    else
      Ember.I18n.t "#{@get("catalogStub")}.section_#{@get("currentSection.category_number")}_prompt"
  ).property("currentSection")


  sectionQuestions: Ember.computed ->
    section = @get("currentSection")

    return [] unless @get("catalog_definitions") and @get("catalogs").contains(section.category)
    catalog_questions = @get("catalog_definitions.#{section.category}")
    catalog_questions[ section.category_number-1 ]

  .property("section.category", "currentSection")

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

  sectionResponses: Ember.computed( -> @get("responsesData").filterBy("catalog", @get("currentCategory")) ).property("currentCategory", "responsesData")

  actions:
    closeCheckin: -> @set("modalOpen", false)
    treatmentEdited: -> @get("treatments").forEach (treatment) -> treatment.set("quantity", parseFloat(treatment.get("quantity")))

    setResponse: (question_name, value) ->
      response = @get("sectionResponses").findBy("name",question_name)

      if Ember.isPresent(response) and value isnt null
        response.set("value", value)
        @send("nextSection") if @get("sectionQuestions.length") is 1

      # TODO raise some error here if question not found?

    setSection: (section) ->
      @set("section", section) if @get("sections").mapBy("number").contains(section)
    nextSection: ->
      @set("section", @get("section")+1) unless @get("section") is @get("sections.lastObject.number")
    previousSection: ->
      @set("section", @get("section")-1) unless @get("section") is @get("sections.firstObject.number")

    save: ->
      data =
        entry:
          JSON.stringify({
            responses: @get("responsesData").rejectBy("value", null) # Don't send null value responses, these are invalid
            notes: @get("notes")
            treatments: @get("treatments").map (treatment) -> treatment.getProperties("name", "quantity", "unit")
          })

      ajax(
        url: "#{config.apiNamespace}/entries/#{@get('date')}.json"
        type: "PUT"
        data: data
      ).then(
        (
          (response) ->
            if @get("checkinComplete") # only process the entry if it's complete
              @get("controllers.graph").send("dayProcessing", @get("date"))
        ).bind(@)
        (response) -> console.log "error!!"
      )

`export default controller`