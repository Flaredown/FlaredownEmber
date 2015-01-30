`import Ember from 'ember'`

mixin = Ember.Mixin.create

  viewportSize:     14
  viewportMinSize:  14
  bufferMin: 20
  # viewportStart
  # firstEntrydate

  ### DATE PICKER STUFF ###
  datePickerWatcher: Ember.observer ->
    Ember.run.later =>
      if @get("pickerStartDate")
        new_start_date = moment(@get("pickerStartDate"))
        change = @get("viewportStart").diff(new_start_date, "days")
        @send("resizeViewport", change, "past") unless new_start_date.isSame(@get("viewportStart"), "day")

      if @get("pickerEndDate")
        new_end_date = moment(@get("pickerEndDate"))
        change = @get("viewportEnd").diff(new_end_date, "days")
        @send("resizeViewport", change, "future") unless new_end_date.isSame(@get("viewportEnd"), "day")

  .observes("pickerStartDate", "pickerEndDate")

  viewportDateWatcher: Ember.observer ->
    Ember.run.later =>
      if @get("viewportStart")
        formatted_start = moment(@get("viewportStart")).format("D MMMM, YYYY")
        @set("pickerStartDate", formatted_start) if @get("pickerStartDate") isnt formatted_start

      if @get("viewportEnd")
        formatted_end = moment(@get("viewportEnd")).format("D MMMM, YYYY")
        @set("pickerEndDate", formatted_end) if @get("pickerEndDate") isnt formatted_end
  .observes("viewportStart")

  ### VIEWPORT SETUP ###
  changeViewport: (size_change, new_start) ->
    today     = moment().utc().startOf("day")
    new_size  = @get("viewportSize")+size_change

    return if today.diff(new_start, "days") <= 0                                                            # Don't accept changes to invalid viewportStart
    new_start = @get("firstEntryDate") if new_start < @get("firstEntryDate")                                # Limit based on firstEntryDate
    new_size  = Math.abs(today.diff(new_start, "days")) if moment(new_start).add(new_size, "days") > today  # Limit based on no time travel
    new_size  = @get("viewportMinSize") if new_size < @get("viewportMinSize")                               # Can't go below min size
    return if moment(new_start).add(new_size, "days") > today                                               # Can't shift viewport past today

    @setProperties
      viewportSize:   new_size
      viewportStart:  new_start

  # viewportStart
  viewportEnd: Ember.computed( -> moment(@get("viewportDays.lastObject")*1000)).property("viewportDays")
  viewportDays: Ember.computed( ->
    [1..@get("viewportSize")].map (i) =>
      moment(@get("viewportStart")).add(i, "days")
    .filter (date) =>
      date >= @get("firstEntryDate") and date <= moment().utc().startOf("day")
    .map (date) ->
      date.unix()
  ).property("viewportSize", "viewportStart")

  ### Loading/Buffering ###
  bufferRadius: Ember.computed( ->
    # radius = Math.floor(@get("viewportSize") / 2)
    radius = @get("viewportSize")
    if radius < @get("bufferMin") then @get("bufferMin") else radius
  ).property("viewportSize")

  bufferWatcher: Ember.observer ->

    if @get("viewportStart") and @get("loadedStartDate") and @get("loadedEndDate")
      days_in_past_buffer   = Math.abs(@get("viewportStart").diff(@get("loadedStartDate"),"days"))
      # days_in_future_buffer = Math.abs(@get("viewportEnd").diff(@get("loadedEndDate"),"days"))

      if days_in_past_buffer < @get("bufferRadius")
        new_loaded_start = moment(@get("loadedStartDate")).subtract(@get("bufferRadius"),"days")
        @loadMore(new_loaded_start, @get("viewportStart")) unless @get("loadingStartDate") <= new_loaded_start

      # TODO deal with future loading later
      # available_future_days = Math.abs(@get("loadedEndDate").diff(moment.utc().startOf("day"),"days"))
      # days_to_load          = if days_in_future_buffer > available_future_days then available_future_days else @get("bufferRadius")
      # days_to_load          = if @get("bufferRadius") > days_to_load then @get("bufferRadius") else days_to_load
      # if days_to_load and available_future_days
      #   console.log "?!!?! #{available_future_days} #{days_in_future_buffer}"
      #   new_loaded_end = moment(@get("loadedEndDate")).add(days_to_load,"days")
      #   ajax(
      #     url: "#{config.apiNamespace}/graph"
      #     method: "GET"
      #     data:
      #       start_date: @get("loadedEndDate").format("MMM-DD-YYYY")
      #       end_date: new_loaded_end.format("MMM-DD-YYYY")
      #   ).then(
      #     (response) =>
      #       @set "loadedEndDate", new_loaded_end
      #       @set "rawData", response
      #       @processRawData()
      #
      #     (response) => console.log "?!?! error on getting graph"
      #   )
  .observes("loadedStartDate", "loadedEndDate", "viewportStart")

  actions:
    resizeViewport: (days, direction) ->
      if typeof(direction) is "undefined" # default direction is both ("pinch")
        @changeViewport (days*2), moment(@get("viewportStart")).subtract(days,"days")
      else
        if direction is "past"
          @changeViewport days, moment(@get("viewportStart")).subtract(days,"days")
        else
          @changeViewport days, moment(@get("viewportStart"))

    shiftViewport: (days, direction) ->
      if direction is "past"
        @changeViewport 0, moment(@get("viewportStart")).subtract(days,"days")
      else # "future"
        @changeViewport 0, moment(@get("viewportStart")).add(days,"days")


`export default mixin`