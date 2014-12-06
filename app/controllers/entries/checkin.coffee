`import Ember from 'ember'`
`import config from '../../config/environment'`

controller = Ember.ObjectController.extend
  titleBinding: "id"
  modalOpen: true

  # Watch some user actions
  modalChanged: Ember.observer ->
    unless @get("modalOpen")
      @transitionToRoute("entries")
      @set("modalOpen", true)
  .observes("modalOpen")

  sectionChanged: Ember.observer ->
    @transitionToRoute("entries.checkin", @get("dateAsParam"), @get("section")) if @get("section")
  .observes("section")

  sections: Ember.computed ->
    accum           = []
    category_count  = 0

    return [] unless @get("catalogs.length")

    @get("catalogs").sort().forEach (catalog) =>
      @get("catalog_definitions.#{catalog}").forEach (section,category_number) =>

        number = category_count+category_number+1
        accum.addObject {
          number: number
          selected: (number is @get("section"))
          category_number: category_number+1
          category: catalog
        }

      category_count = accum.length

    # TODO symptoms sections go here (after catalogs)

    accum

  .property("catalogs", "section")

  currentSection:           Ember.computed( -> @get("sections").objectAt(@get("section")-1) ).property("section", "sections")

  categories:               Ember.computed( -> @get("sections").mapProperty("category").uniq()                ).property("sections")
  currentCategory:          Ember.computed( -> @get("currentSection.category")                                ).property("currentSection")
  currentCategorySections:  Ember.computed( -> @get("sections").filterBy("category", @get("currentCategory")) ).property("currentCategory")

  sectionQuestions: Ember.computed ->
    section = @get("currentSection")

    return [] unless @get("catalog_definitions")
    catalog_questions = @get("catalog_definitions.#{section.category}")
    catalog_questions[ section.category_number-1 ]

  .property("section")

  responsesData: Em.computed ->
    responses = []
    that      = @

    @get("catalogs").sort().forEach (catalog) =>
      @get("catalog_definitions.#{catalog}").forEach (section) =>
        section.forEach (question) ->

          # Lookup an existing response loaded on the Entry, use it's value to setup responsesData, otherwise null
          response  = that.get("responses").findBy("id", "#{catalog}_#{question.name}_#{that.get("model.id")}")
          value     = if response then response.get("value") else null

          responses.push Ember.Object.create({name: question.name, value: value, catalog: catalog})

    responses
  .property("catalog_definitions")

  actions:
    setResponse: (question, value) ->
      console.log value
      # response.set("value", parseInt(value))
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
        url: "#{config.apiNamespace}/entries/#{@get('id')}.json"
        type: "PUT"
        data: data
        success: (response) ->
          null
        error: (response) ->
          console.log "response error !!!"

`export default controller`