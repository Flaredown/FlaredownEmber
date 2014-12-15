transitions = () ->
  @transition(
    @fromRoute('login'),
    @toRoute('register'),
    @use('toLeft'),
    @reverse('toRight')
  )

`export default transitions`