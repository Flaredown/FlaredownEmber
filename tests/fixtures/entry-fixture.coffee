fixture = ->
  id = (new Date).getTime() # crazy stuff for avoiding collisions in store which I *CANNOT* seem to clear
  {
    entry: {
      id: "#{id}",
      date: "Aug-13-2014",
      catalogs: ["hbi", "foo"],
      responses: [
        {
          id: "hbi_general_wellbeing_#{id}",
          name: "general_wellbeing",
          value: 2,
          catalog: "hbi"
        },
        {
          id: "hbi_ab_pain_#{id}",
          name: "ab_pain",
          value: 3
          catalog: "hbi"
        }
      ],
      catalog_definitions: {
        hbi: [
          [{
              name: "general_wellbeing", kind: "select",
              inputs: [
                { value: 0, label: "very_well", meta_label: "happy_face", helper: null},
                { value: 1, label: "slightly_below_par", meta_label: "neutral_face", helper: null},
                { value: 2, label: "poor", meta_label: "frowny_face", helper: null },
                { value: 3, label: "very_poor", meta_label: "sad_face", helper: null },
                { value: 4, label: "terrible", meta_label: "sad_face", helper: null }
              ]
          }],
          [{
              name: "ab_pain", kind: "select",
              inputs: [
                { value: 0, label: "none", meta_label: "happy_face", helper: null},
                { value: 1, label: "mild", meta_label: "neutral_face", helper: null},
                { value: 2, label: "moderate", meta_label: "frowny_face", helper: null},
                { value: 3, label: "severe", meta_label: "sad_face", helper: null}
              ]
          }],
          [{
              name: "stools", kind: "number",
              inputs: [ { value: 0, label: null, meta_label: null, helper: "stools_daily"} ]
          }],
          [{
              name: "ab_mass", kind: "select",
              inputs: [
                { value: 0, label: "none", meta_label: "happy_face", helper: null },
                { value: 1, label: "dubious", meta_label: "neutral_face", helper: null},
                { value: 2, label: "definite", meta_label: "frowny_face", helper: null},
                { value: 3, label: "definite_and_tender", meta_label: "sad_face", helper: null}
              ]
          }],
          [
            { name: "complication_arthralgia", kind: "checkbox"},
            { name: "complication_uveitis", kind: "checkbox"},
            { name: "complication_erythema_nodosum", kind: "checkbox"},
            { name: "complication_aphthous_ulcers", kind: "checkbox"},
            { name: "complication_anal_fissure", kind: "checkbox"},
            { name: "complication_fistula", kind: "checkbox"},
            { name: "complication_abscess", kind: "checkbox"}
          ]
        ],
        foo: [
          [{
              name: "how_fantastic_are_you", kind: "select",
              inputs: [
                { value: 0, label: "very_fantastic", meta_label: "happy_face", helper: null},
                { value: 1, label: "super_fantastic", meta_label: "happy_face", helper: null},
                { value: 2, label: "extra_fantastic", meta_label: "happy_face", helper: null },
                { value: 3, label: "crazy_fantastic", meta_label: "happy_face", helper: null },
              ]
          }]
        ]
      }
    }
  }

`export default fixture`