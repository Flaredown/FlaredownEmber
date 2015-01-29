transitions = () ->

  @transition(
    @toRoute('graph.checkin'),
    @toModel (fromSection) -> @ < fromSection
    @use('toRight')
  );

  @transition(
    @toRoute('graph.checkin'),
    @toModel (fromSection) -> @ > fromSection
    @use('toLeft')
  );

`export default transitions`