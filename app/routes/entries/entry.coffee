`import AuthRoute from '../authenticated'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`

route = AuthRoute.extend
  enter: -> console.log "entered !!!!!!!!!!!!!!!!";
  model: (params, transition, queryParams) ->
    date = params.date
    today = moment.utc().format("MMM-DD-YYYY")
    @set "section", parseInt params.section

    date = today if params.date is "today" or today is params.date

    controller = @controllerFor("entries/entry")
    if controller and controller.get("model.entryDate") is date
      controller.get("model")
    else
      ajax("#{config.apiNamespace}/entries/#{date}").then(
        (response) =>
          if response.entry.id
            Ember.run => @store.find("entry", date)
          else
            Ember.run => @store.createRecord("entry", {catalogs: ["cdai"]}).save() # TODO replace with user catalogs
        ,
        (response) ->
      )

  afterModel: (model, transition, params) ->
    model.set("section", @get("section"))

    # Insert all possible responses for forms to depend on
    model.get("questions").forEach (question) ->
      uuid = "#{question.get("name")}_#{model.get("id")}"
      response = model.get("responses").findBy("id", uuid )
      if response
        response.set("question", question)
      else
        model.get("responses").createRecord({id: uuid , name: question.get("name"), value: null, question: question})

  actions:
    close: -> @transitionTo "entries.index"

`export default route`