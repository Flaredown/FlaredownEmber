`import Ember from 'ember'`
`import config from '../../config/environment'`

controller = Ember.ObjectController.extend
  titleBinding: "id"
  modalOpen: true
  section: 1

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
    sections      = []
    section_total = 0

    return [] unless @get("catalogs.length")

    # TODO symptoms sections go here

    @get("catalogs").sort().forEach (catalog) =>
      Object.keys(@get("catalog_definitions.#{catalog}")).forEach (section,catalog_section) =>

        number = section_total+catalog_section+1
        sections.addObject {number: number, selected: (number is @get("section")), supersection: catalog}

      section_total = sections.length

    sections

  .property("catalogs")

  currentSection: Ember.computed( -> @get("sections").objectAt(@get("section")-1) ).property("section")

  sectionQuestions: Ember.computed ->
    null
    # @get("catalog_definitions.#{catalog}.#{section}").forEach (question) =>
  .property("section")

  # sectionResponses: Ember.computed ->
  #   names = @get("questions").filterBy("section", @get("section")).mapBy("name")
  #   @get("responses").filter (response) -> names.contains(response.get("name"))
  # .property("section", "responses.@each")

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
        url: "#{config.apiNamespace}/entries/#{@get('id')}.json"
        type: "PUT"
        data: data
        success: (response) ->
          null
        error: (response) ->
          console.log "response error !!!"

`export default controller`