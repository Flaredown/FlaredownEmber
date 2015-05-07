`import Ember from 'ember'`
`import config from '../../config/environment'`
`import GroovyResponseHandlerMixin from '../../mixins/groovy_response_handler'`
`import ajax from 'ic-ajax'`

view = Ember.View.extend GroovyResponseHandlerMixin,
  templateName: "questioner/popular-tags"

  didInsertElement: ->
    ajax(
      url: "#{config.apiNamespace}/tags/popular.json"
      type: "GET"
    ).then(
      (response) => @set("popularTags", response)
      @errorCallback.bind(@)
    )



`export default view`