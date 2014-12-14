`import Ember from 'ember'`
`import GroovyResponseHandlerMixin from '../mixins/groovy_response_handler'`

controller = Ember.ObjectController.extend GroovyResponseHandlerMixin,

  actions:
    save: ->
      response = {
        'errors' : {
          'namespace' : 'inline',
          'fields' : {
            'name' : ['empty', 'invalid'],
            'email' : ['invalid']
            'phone' : ['empty']
          }
        }
      }
      @errorCallback(response)

`export default controller`