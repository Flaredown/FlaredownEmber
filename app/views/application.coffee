`import Ember from 'ember'`

view = Ember.View.extend

  didInsertElement: ->
    $('.js-menu-trigger,.js-menu-screen').on 'click touchstart', (e) ->
      $('.js-menu,.js-menu-screen').toggleClass('is-visible')
      e.preventDefault()

    # $(".dropdown-button").click ->
    #   $(".menu").toggleClass("show-menu")
      # $(".menu > li").click ->
      #   debugger
      #   $(".dropdown-button").html($(@).html())
      #   $(".menu").removeClass("show-menu")
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