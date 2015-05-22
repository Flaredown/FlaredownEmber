`import DS from 'ember-data'`
`import config from '../config/environment'`

adapter = DS.ActiveModelAdapter.extend
  # TODO http://emberjs.com/blog/2015/05/21/ember-data-1-0-beta-18-released.html#toc_ds-restadapter-buildurl-refactored-into-different-hooks
  buildURL: (type, id) ->
    url = "#{config.apiNamespace}/current_user"
    url = "#{url}/#{id}" if id isnt "0"

    url

`export default adapter`