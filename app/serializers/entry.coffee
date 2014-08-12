`import DS from 'ember-data'`

serializer = DS.ActiveModelSerializer.extend DS.EmbeddedRecordsMixin,
  attrs:
    responses: {embedded: "always"}
    questions: {embedded: "always"}
    
`export default serializer`