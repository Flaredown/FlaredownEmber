transitions = () ->

  @transition(
    @childOf(".checkin-content")
    @toModel (fromModel) -> (@number > fromModel.number)
    @use('toLeft')
    # @use('checkin-next')
  );

  @transition(
    @childOf(".checkin-content")
    @toModel (fromModel) -> console.log "?!";(@number < fromModel.number)
    @use('toRight')
    # @use('checkin-prev')
  );

`export default transitions`