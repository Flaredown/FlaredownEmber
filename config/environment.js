/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    NOT_CI: process.env.NOT_CI,

    modulePrefix: "flaredown",
    environment: environment,
    baseURL: '/',
    locationType: 'auto',
    apiVersion:      1,
    apiNamespace:    '/v1',
    afterLoginRoute: 'graph',
    ga_id: "UA-62007375-3", // dev
    keen: { // staging
      project_id: "55327e0646f9a75ef4402fc1",
      write_key: "c6222280f213adef6860fff3e431e3d933ed3314e9c9a283133230418d2cd368f11f519bdceaa913ba75e097eb5f1d92435bba3c885ea2417a9179550053f590fac16c0fabc1f44bd1c19206dbce6ddc7ae890312c8e6248a25618286cd9d5966194f07d52e9880b11ee9f5b6ce91ad2",
    },
    pusher: {
      key: "12bdfdebc5307b2d8918",
      app_id: "65526"
    },
    sentry: {
      skipCdn: false, // skip loading from cdn
      cdn: '//cdn.ravenjs.com',
      dsn: 'https://73745d4cc21946d492a13ec751654397@app.getsentry.com/42165',
      version: '1.1.16',
      whitelistUrls: [ 'localhost:4300', 'site.local' ],
      development: false // Set to true, to disable while developing
    },

    contentSecurityPolicy: {
      'default-src': "'self'",
      'script-src': "'self' 'unsafe-inline' 'unsafe-eval' http://*.pusher.com www.google-analytics.com/analytics.js www.google.com/jsapi d26b395fwzu5fz.cloudfront.net api.keen.io cdn.ravenjs.com",
      'font-src': "'self'",
      'connect-src': "`self` http://localhost:* ws://*.pusherapp.com http://*.pusher.com",
      'img-src': "'self' www.google-analytics.com/collect data: app.getsentry.com",
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

    ENV.sentry.development = true;
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

    ENV.sentry.development = true;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'staging') {
    ENV.pusher.key = '40edeaadb34fd870d29e';
    ENV.pusher.app_id = '102551';
    ENV.keen.project_id = '55327e0646f9a75ef4402fc1';
    ENV.keen.write_key = 'c6222280f213adef6860fff3e431e3d933ed3314e9c9a283133230418d2cd368f11f519bdceaa913ba75e097eb5f1d92435bba3c885ea2417a9179550053f590fac16c0fabc1f44bd1c19206dbce6ddc7ae890312c8e6248a25618286cd9d5966194f07d52e9880b11ee9f5b6ce91ad2';
    ENV.ga_id = 'UA-62007375-1';
  }

  if (environment === 'production') {
    // TODO changeme
    ENV.pusher.key = '40edeaadb34fd870d29e';
    ENV.pusher.app_id = '102551';

    ENV.keen.project_id = '55328229672e6c290c2be9cd';
    ENV.keen.write_key = '2cebdf5d1c5aa2d18fd11763ca8639ee0e158d28b5644ec75a91e414a740b668d314f6ea163940c3631c4900ee3a759608cfaeeda9c7f3bb14cb2d58c3950bb60ff54473443d16488b3436b7b1dc5e5d39a712e1a8c9fbbdbf7c119eea79df16aebbd5e76a4c63348f56c7eac064b5aa';
    ENV.ga_id = 'UA-62007375-2';
  }

  return ENV;
};
