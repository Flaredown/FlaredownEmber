fixture = (date) ->
  id    = (new Date).getTime() # crazy stuff for avoiding collisions in store which I *CANNOT* seem to clear
  date ?= "Aug-13-2014"

  {
    entry: {
      id: "#{id}",
      date: date,
      catalogs: ["hbi", "foo"],
      notes: "123 #abc"
      complete: true
      just_created: true
      responses: [
        # { id: "hbi_general_wellbeing_#{id}", name: "general_wellbeing", value: null, catalog: "hbi" }
        { id: "hbi_ab_pain_#{id}", name: "ab_pain", value: 1, catalog: "hbi" }
        { id: "hbi_stools_#{id}", name: "stools", value: 1, catalog: "hbi" }
        { id: "hbi_ab_mass_#{id}", name: "ab_mass", value: 1, catalog: "hbi" }
        { id: "hbi_complication_uveitis_#{id}", name: "complication_uveitis", value: 1, catalog: "hbi" }

        { id: "foo_how_fantastic_are_you_#{id}", name: "how_fantastic_are_you", value: 1, catalog: "foo" }

        { id: "symptoms_droopy lips_#{id}", name: "droopy lips", value: 1, catalog: "symptoms" }
      ],
      treatments: [
        {
          id: "Tickles_25_beans_#{id}"
          name: "Tickles"
          quantity: 25.0
          unit: "session"
        },
        {
          id: "Laughing Gas_20_cc_#{id}"
          name: "Laughing Gas"
          quantity: 20.0
          unit: "cc"
        }
      ],
      catalog_definitions: {
        hbi: [
          [{
              name: "general_wellbeing", kind: "select",
              inputs: [
                { value: 0, label: "very_well", meta_label: "", helper: null},
                { value: 1, label: "slightly_below_par", meta_label: "", helper: null},
                { value: 2, label: "poor", meta_label: "", helper: null },
                { value: 3, label: "very_poor", meta_label: "", helper: null },
                { value: 4, label: "terrible", meta_label: "", helper: null }
              ]
          }],
          [{
              name: "ab_pain", kind: "select",
              inputs: [
                { value: 0, label: "none", meta_label: "", helper: null},
                { value: 1, label: "mild", meta_label: "", helper: null},
                { value: 2, label: "moderate", meta_label: "", helper: null},
                { value: 3, label: "severe", meta_label: "", helper: null}
              ]
          }],
          [{
              name: "stools", kind: "number",
              inputs: [ { value: 0, label: null, meta_label: null, helper: "stools_daily"} ]
          }],
          [{
              name: "ab_mass", kind: "select",
              inputs: [
                { value: 0, label: "none", meta_label: "", helper: null },
                { value: 1, label: "dubious", meta_label: "", helper: null},
                { value: 2, label: "definite", meta_label: "", helper: null},
                { value: 3, label: "definite_and_tender", meta_label: "", helper: null}
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
                { value: 0, label: "very_fantastic", meta_label: "", helper: null},
                { value: 1, label: "super_fantastic", meta_label: "", helper: null},
                { value: 2, label: "extra_fantastic", meta_label: "", helper: null },
                { value: 3, label: "crazy_fantastic", meta_label: "", helper: null },
              ]
          }]
        ],
        conditions: [
          [{
              name: "Crohn's disease", kind: "select",
              inputs: [
                { value: 0, meta_label: "", helper: null},
                { value: 1, meta_label: "", helper: null},
                { value: 2, meta_label: "", helper: null },
                { value: 3, meta_label: "", helper: null },
                { value: 4, meta_label: "", helper: null },
              ]
          }]
        ],
        symptoms: [
          [{
              name: "droopy lips", kind: "select",
              inputs: [
                { value: 0, meta_label: "", helper: null},
                { value: 1, meta_label: "", helper: null},
                { value: 2, meta_label: "", helper: null },
                { value: 3, meta_label: "", helper: null },
                { value: 4, meta_label: "", helper: null },
              ]
          }],
          [{
              name: "fat toes", kind: "select",
              inputs: [
                { value: 0, meta_label: "", helper: null},
                { value: 1, meta_label: "", helper: null},
                { value: 2, meta_label: "", helper: null },
                { value: 3, meta_label: "", helper: null },
                { value: 4, meta_label: "", helper: null },
              ]
          }],
          [{
              name: "slippery tongue", kind: "select",
              inputs: [
                { value: 0, meta_label: "", helper: null},
                { value: 1, meta_label: "", helper: null},
                { value: 2, meta_label: "", helper: null },
                { value: 3, meta_label: "", helper: null },
                { value: 4, meta_label: "", helper: null },
              ]
          }]
        ]
      }
    }
  }

`export default fixture`