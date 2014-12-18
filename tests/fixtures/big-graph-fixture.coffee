fixture = (days) ->

  days ?= 365
  daysFromStart = (days) -> moment().utc().startOf("day").subtract(days, "days").unix()
  randomInt = (min, max) ->
    Math.floor(Math.random() * (max - min)) + min; # max exclusive

  graph = {
    hbi: []
  }

  [0..(days-1)].forEach (i) ->
    graph.hbi.push {x: daysFromStart(i), order: 1, points: randomInt(0,5), name: "fat toes" }
    graph.hbi.push {x: daysFromStart(i), order: 2, points: randomInt(0,5), name: "droopy lips" }
    graph.hbi.push {x: daysFromStart(i), order: 3, points: randomInt(0,5), name: "slippery tongue" }

  graph

`export default fixture`