`import Ember from 'ember'`

fixture = Ember.Object.create({
  "en":{
    "hello":"Hello world",
    "catalogs":{
      "hbi":{
        "section_1_prompt":"How would you rate your general well-being?",
        "general_wellbeing":"General well-being",
        "section_2_prompt":"What is your level of abdominal pain?",
        "ab_pain":"Abdominal pain",
        "section_3_prompt":"How many soft/liquid stools did you pass today?",
        "stools":"Stools",
        "section_4_prompt":"Do you have an abdominal mass?",
        "ab_mass":"Abdominal mass",
        "section_5_prompt":"Check any complications that apply",
        "complication_arthralgia":"Arthalgia",
        "complication_uveitis":"Uveitis",
        "complication_erythema_nodosum":"Eythema Nodosum",
        "complication_aphthous_ulcers":"Apthous Ulcers",
        "complication_anal_fissure":"Anal Fissure",
        "complication_fistula":"Fistula",
        "complication_abscess":"Abscess"
      },
      "rapdi3": {}
    },
    treatment_units: [
      "pill",
      "patch",
      "syringe"
    ],
    location_options: {
      US: "United States"
    },

    onboarding: {
      sex_options: {
        male: "male",
        female: "female",
      },
      highest_education_options: [],
      ethnic_origin_options: [],
      occupation_options: []
    }

  }
})

`export default fixture`