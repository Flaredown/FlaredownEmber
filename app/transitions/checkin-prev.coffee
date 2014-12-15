`import { animate, stop } from "liquid-fire"`

animation = (oldView, insertNewView, opts) ->
    stop(oldView);
    animate(oldView, {opacity: 0}, opts)
      .then(insertNewView)
      .then(
        (newView) ->
          animate(newView, {opacity: [1, 0]}, opts)
      )
`export default animation`