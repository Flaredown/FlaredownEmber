# /v1/graph?start_date=Nov-16-2014&end_date=Dec-06-2014
fixture = (startDate) ->

  startDate = moment(startDate).utc().startOf("day")
  {
    symptoms: [
      {x: startDate.unix(), order: 1, points: 1, name: "fat toes", },
      {x: startDate.unix(), order: 2, points: 1, name: "droopy lips", },
      {x: startDate.unix(), order: 3, points: 1, name: "slippery tongue", },
    ],
    hbi: [
      {x: startDate.unix(), order: 1, points: 1, name: "general_wellbeing", },
      {x: startDate.unix(), order: 2, points: 1, name: "ab_pain", },
      {x: startDate.unix(), order: 3, points: 1, name: "stools", },
      {x: startDate.unix(), order: 4, points: 1, name: "ab_mass", },
      {x: startDate.unix(), order: 5, points: 1, name: "complications", },
    ]
  }

`export default fixture`