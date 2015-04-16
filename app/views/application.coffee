`import Ember from 'ember'`

view = Ember.View.extend

  didInsertElement: ->
    $('.sliding-panel-button,.sliding-panel-fade-screen,.sliding-panel-close, .sliding-panel-content a').on 'click touchstart', (e) ->
      $('.sliding-panel-content,.sliding-panel-fade-screen').toggleClass 'is-visible'
      e.preventDefault()
      return
    return

    $('.dropdown-button').click ->
      $('.dropdown-menu').toggleClass 'show-menu'
      $('.dropdown-menu > li').click ->
        $('.dropdown-menu').removeClass 'show-menu'
        return
      $('.dropdown-menu.dropdown-select > li').click ->
        $('.dropdown-button').html $(this).html()
        return
      return
    return


  willDestroyElement: ->

`export default view`