`import DS from 'ember-data'`
`import config from '../config/environment'`

init = {
  name: "adapter"
  before: 'pusher'

  initialize: (container, application) ->
    DS.ActiveModelAdapter.reopen
      namespace: "api/v#{config.apiVersion}"
}
`export default init`