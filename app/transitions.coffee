transitions = () ->

  @transition(
    @toRoute('graph.checkin'),
    @toModel (to,from) -> to > from
    @use('toRight')
  );

  @transition(
    @toRoute('graph.checkin'),
    @toModel (to, from) -> to < from
    @use('toLeft')
  );

`export default transitions`