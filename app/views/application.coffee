`import Ember from 'ember'`

view = Ember.View.extend

  didInsertElement: ->
    $(".dropdown-button").click ->
      $(".menu").toggleClass("show-menu")
      # $(".menu > li").click ->
      #   debugger
      #   $(".dropdown-button").html($(@).html())
      #   $(".menu").removeClass("show-menu")

  willDestroyElement: ->

`export default view`