`import AuthRoute from '../authenticated'`
`import UserSetupMixin from '../../mixins/user_setup'`
`import config from '../../config/environment'`
`import ajax from 'ic-ajax'`
`import Ember from 'ember'`

route = AuthRoute.extend

  model: ->
    ajax(
      url: "#{config.apiNamespace}/me/catalogs"
    ).then(
      (response) -> response
      (response) -> # TODO handler here
    )

  beforeModel: ->
    @_super()
    @get("currentUser.model").reload().then(
      => UserSetupMixin.apply({}).setupUser(@container)
    )


`export default route`

