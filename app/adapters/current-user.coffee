`import DS from 'ember-data'`

adapter = DS.ActiveModelAdapter.extend
  buildURL: (type, id) ->
    url = "#{FlaredownENV.apiNamespace}/current_user"
    url = "#{url}/#{id}" if id isnt "0"

    url
    
`export default adapter`