transitions = () ->

  @transition(
    @childOf("#questions")
    @toModel (fromModel) -> (@number > fromModel.number)
    @use('toLeft')
    # @use('checkin-next')
  );

  @transition(
    @childOf("#questions")
    @toModel (fromModel) -> (@number < fromModel.number)
    @use('toRight')
    # @use('checkin-prev')
  );

`export default transitions`