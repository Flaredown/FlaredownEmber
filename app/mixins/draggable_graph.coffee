`import Ember from 'ember'`

mixin = Ember.Mixin.create

  ### CONTROL FUNCTIONALITY ###
  draggable: 'true'
  attributeBindings: 'draggable'
  graphShifted: false

  touchStart: (event) ->
    @dehighlightPips()
    @set "dragStartX", event.originalEvent.touches[0].pageX
    @set "dragStartY", event.originalEvent.touches[0].pageY
  touchMove:  (event) ->
    @dragGraph event.originalEvent.touches[0].pageX
  touchEnd: (event) ->
    @changeViewport()
  dragStart:  (event) ->
    @dehighlightPips()
    event.dataTransfer.setDragImage(window.dragImg, 0, 0)
    event.dataTransfer.setData("text/plain", "")
    @set "dragStartX", event.originalEvent.pageX
    @set "dragStartY", event.originalEvent.pageY
  dragOver: (event) -> @dragGraph event.originalEvent.pageX
  dragEnd:    (event) -> @changeViewport()

  _insideDragContainer: (x, y) ->
    dragContainer = @get("dragContainer")
    return false if x < 0
    return false if y < 0
    width  = dragContainer.width()
    height = dragContainer.height()
    offset = dragContainer.offset()

    return x >= offset.left and x <= offset.left + width and y >= offset.top and y <= offset.top + height

  dragGraph: (pixels) ->
    startX = @get("dragStartX")
    startY = @get("dragStartY")

    if @get("viewportDays.length") and @_insideDragContainer(startX, startY) and pixels > 0
      difference          = pixels - startX
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

      @get("controller").send("shiftViewport", days, direction)

    @set "dragStartX", false
    @set "graphShifted", true

  shift: Ember.observer ->
    @get("allCanvases").attr("transform", "translate(" + @get("shiftGraphPx") + "," + @get("margin").top + ")")
  .observes("shiftGraphPx")

  resetGraphShift: ->
    @set "graphShifted", false
    @get("allCanvases").attr("transform", "translate(" + @get("margin").left + "," + @get("margin").top + ")")

`export default mixin`
