`import DS from 'ember-data'`
`import config from '../config/environment'`

adapter = DS.ActiveModelAdapter.extend
  buildURL: (type, id) ->
    url = "#{config.apiNamespace}/current_user"
    url = "#{url}/#{id}" if id isnt "0"

    url
    
`export default adapter`