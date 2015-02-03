/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: "flaredown",
    environment: environment,
    baseURL: '/',
    locationType: 'auto',
    apiVersion:      1,
    apiNamespace:    '/v1',
    afterLoginRoute: 'graph',
    pusher: {
      key: "12bdfdebc5307b2d8918",
      app_id: "65526"
    },

    contentSecurityPolicy: {
      'default-src': "'self'",
      'script-src': "'self' http://*.pusher.com 'unsafe-inline' 'unsafe-eval'",
      'font-src': "'self'",
      'connect-src': "`self` http://localhost:* ws://*.pusherapp.com http://*.pusher.com",
      'img-src': "'self'",
      'style-src': "'self' 'unsafe-inline'",
      'frame-src': ""
    },

    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    }
  };

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    ENV.APP.LOG_ACTIVE_GENERATION = true;
    ENV.APP.LOG_TRANSITIONS = true;
    ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'none';
    ENV.pusher.key = null; // don't use pusher in tests

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = true;
    ENV.APP.LOG_TRANSITIONS = true;
    ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    ENV.APP.LOG_VIEW_LOOKUPS = true;


    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'staging') {
    ENV.pusher.key = '40edeaadb34fd870d29e';
    ENV.pusher.app_id = '102551';
  }

  if (environment === 'production') {
    // TODO changeme
    ENV.pusher.key = '40edeaadb34fd870d29e';
    ENV.pusher.app_id = '102551';
  }

  return ENV;
};
