transitions = () ->

  @transition(
    @toRoute('graph.checkin'),
    @toModel (toSection,fromSection) -> toSection < fromSection
    @use('toRight')
  );

  @transition(
    @toRoute('graph.checkin'),
    @toModel (toSection, fromSection) -> toSection > fromSection
    @use('toLeft')
  );

`export default transitions`