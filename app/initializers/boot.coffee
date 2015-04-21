`import config from '../config/environment'`
# `import Keen from 'npm:keen-js'`

init = {
  name: "boot"
  before: 'adapter'

  initialize: (container, application) ->
    # Create Google Analytics Tracker
    if typeof(ga) isnt "undefined"
      options = {}
      options = {'cookieDomain': 'none'} if config.environment is "development"
      ga('create', config.ga_id, options)

    if typeof(Keen) isnt "undefined"
      window.keen = new Keen
        projectId: config.keen.project_id   # String (required always)
        writeKey: config.keen.write_key     # String (required for sending data)
        # readKey: "YOUR_READ_KEY",       # String (required for querying data)
        protocol: "https"              # String (optional: https | http | auto)
        host: "api.keen.io/3.0"        # String (optional)
        requestType: "jsonp"            # String (optional: jsonp, xhr, beacon)
}
`export default init`