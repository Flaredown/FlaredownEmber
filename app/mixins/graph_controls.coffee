`import Ember from 'ember'`

computed = Ember.computed

mixin = Ember.Mixin.create
  filtered: [] # default to no filtering

  filterableNames: computed("rawData", ->
    _names = []
    @get("sources").forEach (source) =>
      @get("rawData.#{source}").mapBy("name").uniq().forEach (name) -> _names.pushObject([source,name])
    _names
  )

  # Filterables, or trackables, are things that can be filtered off/on the graph
  # e.g. treatments, symptoms, catalog responses
  filterables: computed("filterableNames", "filtered.@each", ->
    filtered = @get("filtered")
    @get("filterableNames").map (name_array) =>
      [source,name] = name_array
      psuedoCatalog = ["treatments", "symptoms", "conditions"].contains(source)
      id            = "#{source}_#{name}"
      type          = if source is "treatments" then "treatment" else "symptom"
      name          = if psuedoCatalog then name else Em.I18n.t("catalogs.#{source}.#{name}")

      id:       id
      name:     name
      source:   source
      color:    @colorClasses(id).bg
      filtered: filtered.contains(id)
  )

  ### Filter helpers ###
  activeFilterables:    computed.filterBy("filterables", "filtered", true)
  inactiveFilterables:  computed.filterBy("filterables", "filtered", false)
  catalogFilterables:   computed("filterables", "catalog", -> @get("filterables").filterBy("source", @get("catalog")) )
  conditionFilterables: computed.filterBy("filterables", "source", "conditions")
  symptomFilterables: computed.filterBy("filterables", "source", "symptoms")
  treatmentFilterables: computed.filterBy("filterables", "source", "treatments")
  visibleTreatmentFilterables: computed("treatmentFilterables", "treatmentViewportDatumNames", ->
    uniqVisibles = @get("treatmentViewportDatumNames").uniq()
    @get("treatmentFilterables").filter( (filterable) => uniqVisibles.contains(filterable.name) )
  )

  ### Controls text helpers ###
  numFilteredTreatments: computed "treatmentFilterables", ->
    name = Em.I18n.t("treatments").toLowerCase()
    total = @get("treatmentFilterables.length")
    notFiltered = @get("treatmentFilterables").rejectBy("filtered").length

    if total is notFiltered then Em.I18n.t("all_things", things: name) else Em.I18n.t("x_of_y_things", x: notFiltered, y: total, things: name)

  numFilteredConditions: computed "conditionFilterables", ->
    name = Em.I18n.t("conditions").toLowerCase()
    total = @get("conditionFilterables.length")
    notFiltered = @get("conditionFilterables").rejectBy("filtered").length

    if total is notFiltered then Em.I18n.t("all_things", things: name) else Em.I18n.t("x_of_y_things", x: notFiltered, y: total, things: name)

  numFilteredSymptoms: computed "symptomFilterables", ->
    name = Em.I18n.t("symptoms").toLowerCase()
    total = @get("symptomFilterables.length")
    notFiltered = @get("symptomFilterables").rejectBy("filtered").length

    if total is notFiltered then Em.I18n.t("all_things", things: name) else Em.I18n.t("x_of_y_things", x: notFiltered, y: total, things: name)

  actions:
    changeCatalog: (catalog) -> @set("catalog", catalog)

    filter: (filterable_id) ->
      filtered = @get("filtered")
      if filtered.contains filterable_id
        filtered.removeObject filterable_id
      else
        filtered.pushObject filterable_id

      @propertyDidChange("filtered")
`export default mixin`
