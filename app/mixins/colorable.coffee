`import Ember from 'ember'`

mixin = Ember.Mixin.create

  colorClasses: (uniq_name, type) ->
    colors    = window["#{type}Colors"]
    color     = colors.find((colorable) => colorable[0] is uniq_name)

    id        = if color then color[1] else ""
    type_key  = if type is "treatment" then "t" else "s"
    {
      bg:     "#{type_key}bg-#{id}"
      fill:   "#{type_key}fill-#{id}"
      color:  "#{type_key}clr-#{id}"
      border:  "#{type_key}border-#{id}"
    }

`export default mixin`
