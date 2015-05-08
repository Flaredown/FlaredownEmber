`import Ember from 'ember'`

view = Ember.View.extend

  templateName: "header"
  userWatcher: Em.observer(-> @activateMenu() ).observes("currentUser.loggedIn", "currentUser.onboarded")
  didInsertElement: -> @activateMenu()

  activateMenu: ->
    Ember.run.next =>
      $('.sliding-panel-button,.sliding-panel-fade-screen,.sliding-panel-close, .sliding-panel-content a').on 'click touchstart', (e) ->
        $('.sliding-panel-content,.sliding-panel-fade-screen').toggleClass 'is-visible'
        e.preventDefault()

      $('.dropdown-button').click ->
        $('.dropdown-menu').toggleClass 'show-menu'
        $('.dropdown-menu > li').click ->
          $('.dropdown-menu').removeClass 'show-menu'

        # Don't replace menu selection, we just want the menu to stay the same
        # $('.dropdown-menu.dropdown-select > li').click ->
        #   $('.dropdown-button').html $(@).html()

      $("body").click (event) ->
        $('.dropdown-menu').removeClass 'show-menu' unless event.target.className is "dropdown-button"


`export default view`