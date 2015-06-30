`import Ember from 'ember'`

mixin = Ember.Mixin.create

  ### CONTROL FUNCTIONALITY ###
  # TODO Renable for Graph Release, and fix bug that allows dragging from foreground
  # draggable: 'true'
  # attributeBindings: 'draggable'
  graphShifted: false

  touchStart: (event) -> @dehighlightPips(); @set "dragStartX", event.originalEvent.touches[0].pageX
  touchMove:  (event) -> @dragGraph event.originalEvent.touches[0].pageX
  touchEnd:   (event) -> @changeViewport()

  dragStart:  (event) ->
    @dehighlightPips()
    event.dataTransfer.setDragImage(window.dragImg, 0, 0)
    event.dataTransfer.setData("text/plain", "")
    @set "dragStartX", event.originalEvent.pageX

  dragOver: (event) -> @dragGraph event.originalEvent.pageX
  dragEnd:    (event) -> @changeViewport()

  dragGraph: (pixels) ->
    if @get("viewportDays.length") and @get("dragStartX") and pixels > 0
      difference          = pixels - @get("dragStartX")
      @set "shiftGraphPx", difference * @get("dragAmplifier")

  changeViewport: ->
    translation         = Math.abs(@get("shiftGraphPx"))
    direction           = if @get("shiftGraphPx") > 0 then "past" else "future"

    if translation > @get("pipWidth")
      days = Math.floor(Math.round(translation / @get("pipWidth")))

      # If graph timeline is overrun, just reset it
      if direction is "future"
        if @get("viewportDays.lastObject") is moment.utc().startOf("day").unix()
          @resetGraphShift()
        else if moment(@get("viewportDays.lastObject")*1000).utc().startOf("day").add(days, "days") > moment.utc().startOf("day")
          days-- until moment(@get("viewportDays.lastObject")*1000).utc().startOf("day").add(days, "days").unix() is moment.utc().startOf("day").unix()

      @controller.send("shiftViewport", days, direction)

    @set "dragStartX", false
    @set "graphShifted", true

  shift: Ember.observer ->
    @get("mainG").attr("transform", "translate(" + @get("shiftGraphPx") + "," + @get("margin").top + ")")
  .observes("shiftGraphPx")

  resetGraphShift: ->
    @set "graphShifted", false
    @get("mainG").attr("transform", "translate(" + @get("margin").left + "," + @get("margin").top + ")")

`export default mixin`