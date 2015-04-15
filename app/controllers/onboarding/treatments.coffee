`import Ember from 'ember'`
`import config from '../../config/environment'`
`import TrackablesMixin from '../../mixins/trackables_controller'`

controller = Ember.Controller.extend TrackablesMixin,
  translationRoot: "onboarding"
  actions:
    save: -> true

`export default controller`