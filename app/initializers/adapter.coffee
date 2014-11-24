`import DS from 'ember-data'`
`import config from '../config/environment'`

init = {
  name: "adapter"
  before: 'pusher'

  initialize: (container, application) ->
    DS.ActiveModelAdapter.reopen
      namespace: "v#{config.apiVersion}" # /v1
}
`export default init`