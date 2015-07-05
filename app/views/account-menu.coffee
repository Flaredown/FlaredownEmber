`import Ember from 'ember'`

view = Ember.View.extend
  templateName: "account-menu"
  userWatcher: Em.observer(-> @setupMenu() ).observes("currentUser.loggedIn", "currentUser.onboarded")
  didInsertElement: -> @setupMenu()

  setupMenu: ->
    Ember.run.next =>
      $('.sliding-panel-button,.sliding-panel-fade-screen,.sliding-panel-close, .sliding-panel-content a').on 'click tap', (e) ->
        $('.sliding-panel-content,.sliding-panel-fade-screen').toggleClass 'is-visible'
        e.preventDefault()

      $('.dropdown-button').on "click tap", ->
        $('.dropdown-menu').toggleClass 'show-menu'
        $('.dropdown-menu > li').on "click tap", ->
          $('.dropdown-menu').removeClass 'show-menu'

        # Don't replace menu selection, we just want the menu to stay the same
        # $('.dropdown-menu.dropdown-select > li').click ->
        #   $('.dropdown-button').html $(@).html()

      $("body").on "click touchstart", (event) ->
        $('.dropdown-menu').removeClass 'show-menu' unless event.target.className is "dropdown-button"


`export default view`