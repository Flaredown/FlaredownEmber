# /v1/graph?start_date=Nov-16-2014&end_date=Dec-06-2014
fixture = (startDate) ->

  startDate ?= moment().utc()

  daysAgo = (days) -> moment(startDate).startOf("day").utc().subtract(days, "days").unix()

  {
    symptoms: [
      # Day 0, is today, and the last day on the graph in terms of x
      {x: daysAgo(0), order: 1, points: 2, name: "fat toes", },
      {x: daysAgo(0), order: 2, points: 3, name: "droopy lips", },
      {x: daysAgo(0), order: 3, points: 1, name: "slippery tongue", },

      {x: daysAgo(1), order: 1, points: 2, name: "fat toes", },
      {x: daysAgo(1), order: 2, points: 3, name: "droopy lips", },
      {x: daysAgo(1), order: 3, points: 1, name: "slippery tongue", },

      {x: daysAgo(2), order: 1, points: 2, name: "fat toes", },
      {x: daysAgo(2), order: 2, points: 3, name: "droopy lips", },
      {x: daysAgo(2), order: 3, points: 1, name: "slippery tongue", },

    ],
    hbi: [
      {x: daysAgo(0), order: 1, points: 2, name: "general_wellbeing", },
      {x: daysAgo(0), order: 2, points: 1, name: "ab_pain", },
      {x: daysAgo(0), order: 3, points: 1, name: "stools", },
      {x: daysAgo(0), order: 4, points: 2, name: "ab_mass", },
      {x: daysAgo(0), order: 5, points: 2, name: "complications", },

      {x: daysAgo(1), order: 1, points: 2, name: "general_wellbeing", },
      {x: daysAgo(1), order: 2, points: 3, name: "ab_pain", },
      {x: daysAgo(1), order: 3, points: 1, name: "stools", },
      {x: daysAgo(1), order: 4, points: 1, name: "ab_mass", },
      {x: daysAgo(1), order: 5, points: 1, name: "complications", },

      {x: daysAgo(2), order: 1, points: 4, name: "general_wellbeing", },
      {x: daysAgo(2), order: 2, points: 4, name: "ab_pain", },
      {x: daysAgo(2), order: 3, points: 1, name: "stools", },
      {x: daysAgo(2), order: 4, points: 1, name: "ab_mass", },
      {x: daysAgo(2), order: 5, points: 5, name: "complications", },

      # Day 3 missing, oh no!

      {x: daysAgo(4), order: 1, points: 0, name: "general_wellbeing", },
      {x: daysAgo(4), order: 2, points: 0, name: "ab_pain", },
      {x: daysAgo(4), order: 3, points: 1, name: "stools", },
      {x: daysAgo(4), order: 4, points: 0, name: "ab_mass", },
      {x: daysAgo(4), order: 5, points: 0, name: "complications", },

      {x: daysAgo(5), order: 1, points: 2, name: "general_wellbeing", },
      {x: daysAgo(5), order: 2, points: 3, name: "ab_pain", },
      {x: daysAgo(5), order: 3, points: 1, name: "stools", },
      {x: daysAgo(5), order: 4, points: 1, name: "ab_mass", },
      {x: daysAgo(5), order: 5, points: 0, name: "complications", },
    ]
  }

`export default fixture`