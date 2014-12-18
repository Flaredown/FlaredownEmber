# /v1/graph?start_date=Nov-16-2014&end_date=Dec-06-2014
fixture = (startDate) ->

  daysFromStart = (days) -> moment(startDate).add(days, "days").unix()

  {
    symptoms: [
      {x: daysFromStart(0), order: 1, points: 2, name: "fat toes", },
      {x: daysFromStart(0), order: 2, points: 3, name: "droopy lips", },
      {x: daysFromStart(0), order: 3, points: 1, name: "slippery tongue", },

      {x: daysFromStart(1), order: 1, points: 2, name: "fat toes", },
      {x: daysFromStart(1), order: 2, points: 3, name: "droopy lips", },
      {x: daysFromStart(1), order: 3, points: 1, name: "slippery tongue", },

      {x: daysFromStart(2), order: 1, points: 2, name: "fat toes", },
      {x: daysFromStart(2), order: 2, points: 3, name: "droopy lips", },
      {x: daysFromStart(2), order: 3, points: 1, name: "slippery tongue", },

    ],
    hbi: [
      {x: daysFromStart(0), order: 1, points: 2, name: "general_wellbeing", },
      {x: daysFromStart(0), order: 2, points: 1, name: "ab_pain", },
      {x: daysFromStart(0), order: 3, points: 1, name: "stools", },
      {x: daysFromStart(0), order: 4, points: 2, name: "ab_mass", },
      {x: daysFromStart(0), order: 5, points: 2, name: "complications", },

      {x: daysFromStart(1), order: 1, points: 2, name: "general_wellbeing", },
      {x: daysFromStart(1), order: 2, points: 3, name: "ab_pain", },
      {x: daysFromStart(1), order: 3, points: 1, name: "stools", },
      {x: daysFromStart(1), order: 4, points: 1, name: "ab_mass", },
      {x: daysFromStart(1), order: 5, points: 1, name: "complications", },

      {x: daysFromStart(2), order: 1, points: 4, name: "general_wellbeing", },
      {x: daysFromStart(2), order: 2, points: 4, name: "ab_pain", },
      {x: daysFromStart(2), order: 3, points: 1, name: "stools", },
      {x: daysFromStart(2), order: 4, points: 1, name: "ab_mass", },
      {x: daysFromStart(2), order: 5, points: 5, name: "complications", },

      # Day 3 missing, oh no!

      {x: daysFromStart(4), order: 1, points: 0, name: "general_wellbeing", },
      {x: daysFromStart(4), order: 2, points: 0, name: "ab_pain", },
      {x: daysFromStart(4), order: 3, points: 1, name: "stools", },
      {x: daysFromStart(4), order: 4, points: 0, name: "ab_mass", },
      {x: daysFromStart(4), order: 5, points: 0, name: "complications", },

      {x: daysFromStart(5), order: 1, points: 2, name: "general_wellbeing", },
      {x: daysFromStart(5), order: 2, points: 3, name: "ab_pain", },
      {x: daysFromStart(5), order: 3, points: 1, name: "stools", },
      {x: daysFromStart(5), order: 4, points: 1, name: "ab_mass", },
      {x: daysFromStart(5), order: 5, points: 0, name: "complications", },
    ]
  }

`export default fixture`