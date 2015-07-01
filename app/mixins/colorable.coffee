`import Ember from 'ember'`

mixin = Ember.Mixin.create

  colorClasses: (uniq_name, type) ->

    colors    = window["colors"]
    color     = colors.find((colorable) => colorable[0] is uniq_name)

    id        = if color then color[1] else ""
    {
      bg:     "colorable-bg-#{id}"
      fill:   "colorable-fill-#{id}"
      color:  "colorable-clr-#{id}"
      border: "colorable-border-#{id}"
      stroke: "colorable-stroke-#{id}"
    }

`export default mixin`
