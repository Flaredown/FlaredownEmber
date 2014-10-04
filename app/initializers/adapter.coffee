`import DS from 'ember-data'`

init = {
  name: "adapter"
  before: 'pusher'

  initialize: (container, application) ->
    DS.ActiveModelAdapter.reopen
      namespace: "api/v#{FlaredownENV.apiVersion}"
}
`export default init`