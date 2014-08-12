`import Ember from 'ember'`
`import AuthRoute from '../authenticated'`

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
      $.get("#{FlaredownENV.apiNamespace}/entries/#{date}", {by_date: true}).then(
        (response) =>
          if response.id
            @store.find("entry", response.id)
          else
            @store.createRecord("entry", {catalogs: ["cdai"]}).save()
        ,
        (response) =>
          debugger
      )
    
  afterModel: (model, transition, params) ->
    model.set("section", @get("section"))
    
    # Insert all possible responses for forms to depend on
    model.get("questions").forEach (question) ->
      _uuid = uuid question.get("name"), model.get("id")
      response = model.get("responses").findBy("id", _uuid )
      if response
        response.set("question", question)
      else
        model.get("responses").createRecord({id: _uuid , name: question.get("name"), value: null, question: question})
    
  actions:
    close: -> @transitionTo "entries.index"

`export default route`