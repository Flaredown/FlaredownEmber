# /v1/graph?start_date=Nov-16-2014&end_date=Dec-06-2014
fixture = ->
  {
    graph: [{
      name: "hbi",
      scores: [
        {x: 1414108800, y: 260},
        {x: 1414195200, y: 301},
        {x: 1414281600, y: 288}
      ],
      components: [ ]
    }]
  }

`export default fixture`