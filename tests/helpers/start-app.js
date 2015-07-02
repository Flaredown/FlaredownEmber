import Ember from 'ember';
import Application from '../../app';
import Router from '../../router';
import config from '../../config/environment';
import helpers from '../helpers/helper-functions';
import userFixture from "../fixtures/user-fixture";
import localeFixture from "../fixtures/locale-fixture";

export default function startApp(attrs) {
  var application;
  helpers(); // slap those suckers on the global namespace

  var attributes = Ember.merge({}, config.APP);
  attributes = Ember.merge(attributes, attrs); // use defaults, but you can override;

  $.mockjaxSettings.contentType = "application/json";
  $.mockjaxSettings.responseTime = 10;

  $.mockjax({url: `${config.apiNamespace}/locales/en`, responseText: localeFixture()});
  $.mockjax({url: `${config.apiNamespace}/current_user`, responseText: userFixture()});

  Ember.run(function() {
    application = Application.create(attributes);
    application.setupForTesting();
    application.injectTestHelpers();
  });

  Ember.run(function() {
    // this shouldn't be needed, i want to be able to "start an app at a specific URL"
    application.reset();
  });

  Ember.run.next(function () {
    // kill liquid fire transitions
    application.__container__.lookup("transitions:map").reopen({
      _map: {}
    });
  });

  return application;
}
