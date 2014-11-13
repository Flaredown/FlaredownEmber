`import AuthRoute from '../authenticated'`
`import config from '../../config/environment'`

route = AuthRoute.extend
  model: (params, transition, queryParams) ->
    date = params.date
    today = moment().format("MMM-DD-YYYY")
    @set "section", parseInt params.section

    date = today if params.date is "today" or today is params.date

    controller = @controllerFor("entries/entry")
    if controller and controller.get("model.entryDate") is date
      controller.get("model")
    else
      $.get("#{config.apiNamespace}/entries/#{date}", {by_date: true}).then(
        (response) =>
          if response.id
            @store.find("entry", response.id)
          else
            @store.createRecord("entry", {catalogs: ["cdai"]}).save() # TODO replace with user catalogs
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