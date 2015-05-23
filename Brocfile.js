/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var ENV = process.env.EMBER_ENV
var app = new EmberApp({
  dotEnv: {
    clientAllowedKeys: ['NOT_CI']
  },
  fingerprint: {
    enabled: (ENV != "development")
  },
  minifyCSS: {
    enabled: (ENV != "development")
  },
  minifyJS: {
    enabled: (ENV != "development")
  }
});

// Keen pageview tracking prereqs
app.import('bower_components/purl/purl.js');
app.import('bower_components/ua-parser-js/src/ua-parser.js');
app.import('bower_components/uuid-js/lib/uuid.js');
app.import('bower_components/jquery-cookie/jquery.cookie.js');

app.import('bower_components/fastclick/lib/fastclick.js');

app.import('bower_components/moment/moment.js');

app.import('bower_components/pusher/dist/pusher.js');

app.import('bower_components/d3/d3.js');

app.import('bower_components/sweetalert/lib/sweet-alert.js');
app.import('bower_components/sweetalert/lib/sweet-alert.css');

app.import('bower_components/jbox/Source/jBox.js');
app.import('bower_components/jbox/Source/jBox.css');

app.import('bower_components/pickadate/lib/picker.js');
app.import('bower_components/pickadate/lib/picker.date.js');
app.import('bower_components/pickadate/lib/themes/default.css');
app.import('bower_components/pickadate/lib/themes/default.date.css');

app.import('bower_components/select2/select2.js');
app.import('bower_components/select2/select2.css');

app.import({development: 'bower_components/jquery-mockjax/jquery.mockjax.js'});
app.import({development: 'bower_components/jquery-simulate/jquery.simulate.js'});

app.import('bower_components/ember-i18n/lib/i18n.js');

// No Graph for now
// removeFile = require('broccoli-file-remover');
// mergeTrees = require('broccoli-merge-trees');
//
// appTree = app.toTree()
//
// filteredTree = removeFile(appTree, {
//   paths: ["assets/flaredown/controllers"],
// });
//
// module.exports = mergeTrees([filteredTree]);
module.exports = app.toTree();
