`import Ember from 'ember'`
`import config from '../../config/environment'`

controller = Ember.ObjectController.extend
  modalOpen: true

  # Watch some user actions
  modalChanged: Ember.observer ->
    unless @get("modalOpen")
      @transitionToRoute("graph")
      @set("modalOpen", true)
  .observes("modalOpen")

  sectionChanged: Ember.observer ->
    @transitionToRoute("graph.checkin", @get("dateAsParam"), @get("section")) if @get("section")
  .observes("section")

  catalogsSorted: Ember.computed(->
    catalogs = @get("catalogs")
    catalogs.removeObject("symptoms")
    catalogs.sort()
    catalogs.addObject("symptoms")
  ).property("catalogs")

  ### Sections: All the pages in the checkin form ###
  sections: Ember.computed ->
    accum           = []
    category_count  = 0

    return [] unless @get("catalogs.length")

    # Start page
    accum.addObject
      number: 1
      selected: category_count+1 is @get("section")
      category_number: 1
      category: "start"

    category_count++

    @get("catalogsSorted").forEach (catalog) =>
      @get("catalog_definitions.#{catalog}").forEach (section,category_number) =>

        number = category_count+category_number+1
        accum.addObject {
          number: number
          selected: number is @get("section")
          category_number: category_number+1
          category: catalog
        }

      category_count = accum.length

    # End page
    accum.addObject
      number: accum.length+1
      selected: category_count+1 is @get("section")
      category_number: 1
      category: "finish"

    accum

  .property("catalogs", "section")

  currentSection:           Ember.computed( -> @get("sections").objectAt(@get("section")-1) ).property("section", "sections.@each")

  categories:               Ember.computed( -> @get("sections").mapProperty("category").uniq()                ).property("sections")
  currentCategory:          Ember.computed( -> @get("currentSection.category")                                ).property("currentSection")
  currentCategorySections:  Ember.computed( -> @get("sections").filterBy("category", @get("currentCategory")) ).property("currentCategory")

  isStart:  Ember.computed.equal("currentCategory", "start")
  isFinish: Ember.computed.equal("currentCategory", "finish")

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

    return [] unless @get("catalog_definitions") and not ["start", "finish"].contains(section.category)
    catalog_questions = @get("catalog_definitions.#{section.category}")
    catalog_questions[ section.category_number-1 ]

  .property("section.category", "currentSection")

  responsesData: Ember.computed ->
    responses = []
    that      = @

    @get("catalogsSorted").forEach (catalog) =>
      @get("catalog_definitions.#{catalog}").forEach (section) =>
        section.forEach (question) ->

          # Lookup an existing response loaded on the Entry, use it's value to setup responsesData, otherwise null
          response  = that.get("responses").findBy("id", "#{catalog}_#{question.name}_#{that.get("model.id")}")
          value     = if response then response.get("value") else null

          responses.pushObject Ember.Object.create({name: question.name, value: value, catalog: catalog})

    responses
  .property("catalog_definitions")

  sectionResponses: Ember.computed( -> @get("responsesData").filterBy("catalog", @get("currentCategory")) ).property("currentCategory", "responsesData")

  actions:
    setResponse: (question_name, value) ->
      response = @get("sectionResponses").findBy("name",question_name)

      if Ember.isPresent(response) and value isnt null
        response.set("value", value)
        @send("nextSection")
        @send("save")

      # TODO raise some error here if question not found?

    setSection: (section) ->
      @set("section", section) if @get("sections").mapBy("number").contains(section)
    nextSection: ->
      @set("section", @get("section")+1) unless @get("section") is @get("sections.lastObject.number")
    previousSection: ->
      @set("section", @get("section")-1) unless @get("section") is @get("sections.firstObject.number")

    save: ->
      that = @

      # Don't send null value responses, these are invalid
      cleanedResponses = @get("responsesData").rejectBy("value", null)

      data =
        entry:
          JSON.stringify({responses: cleanedResponses})

      $.ajax
        url: "#{config.apiNamespace}/entries/#{@get('date')}.json"
        type: "PUT"
        data: data
        success: (response) ->
          null
        error: (response) ->
          console.log "response error !!!"

`export default controller`