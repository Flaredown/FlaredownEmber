`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`

route = Ember.Route.extend GroovyResponseHandlerMixin,
  model: (params, transition, queryParams) ->
    date = params.date
    today = moment().format("MMM-DD-YYYY")
    @set "section", parseInt params.section

    date = today if params.date is "today" or today is params.date

    controller = @controllerFor("graph.checkin")
    if controller and controller.get("model.niceDate") is date
      controller.get("model")
    else
      ajax(
        "#{config.apiNamespace}/entries",
        type: "POST",
        data:
          date: date
      ).then(
        (response) =>
          @store.pushPayload "entry", response
          @store.find "entry", response.entry.id
        @errorCallback.bind(@)
      )

  afterModel: (model, transition, params) ->
    @_super()
    controller = @controllerFor("graph.checkin")
    model.set("section", @get("section"))

    if not model.get("just_created") and transition.params["graph.checkin"].date.toUpperCase() isnt model.get("fancyDate").toUpperCase()
      Ember.run.next =>
        summarySection = controller.get("sections.lastObject").number
        model.set("section", summarySection)

    has_notes = Em.isPresent(model.get("notes"))
    if has_notes
      Ember.run.next => controller.set("show_notes", has_notes)

  actions:
    close: -> @transitionTo "graph"

`export default route`

