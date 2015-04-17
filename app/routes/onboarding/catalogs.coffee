`import AuthRoute from '../authenticated'`
`import UserSetupMixin from '../../mixins/user_setup'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import Ember from 'ember'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

route = AuthRoute.extend GroovyResponseHandlerMixin,

  model: ->
    ajax(
      url: "#{config.apiNamespace}/me/catalogs"
    ).then(
      (response) -> response
      @errorCallback.bind(@)
    )

  beforeModel: ->
    @_super()
    @get("currentUser.model").reload().then(
      => UserSetupMixin.apply({}).setupUser(@container)
    )


`export default route`

