/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var app = new EmberApp({
  sassOptions: {
    includePaths: require('node-neat').with('app/styles/bitters')
  }
});

// app.import('assets/fonts/*', {
//   destDir: 'assets'
// });

var pickFiles = require('broccoli-static-compiler');
var fonts = pickFiles('app/assets/fonts', {
   srcDir: '/',
   files: ['*'],
   destDir: '/assets'
});
var images = pickFiles('app/assets/img', {
   srcDir: '/',
   files: ['*'],
   destDir: '/assets'
});

// var d3 = pickFiles("bower_components/d3", {
//   srcDir: '/',
//   files: ['d3.js'],
//   destDir: '/assets'
// })

app.import('bower_components/pusher/dist/pusher.js');
app.import('bower_components/moment/moment.js');
app.import('bower_components/d3/d3.js');
app.import('bower_components/sweetalert/lib/sweet-alert.js');
app.import('bower_components/sweetalert/lib/sweet-alert.css');
app.import('bower_components/jbox/Source/jBox.js');
app.import('bower_components/jbox/Source/jBox.css');

app.import({development: 'bower_components/jquery-mockjax/jquery.mockjax.js'});
app.import({development: 'bower_components/jquery-simulate/jquery.simulate.js'});

// app.import('vendor/bootstrap/js/transition.js');
// app.import('vendor/bootstrap/js/modal.js');
// app.import('vendor/bootstrap/js/dropdown.js');

// Use `app.import` to add additional libraries to the generated
// output files.
//
// If you need to use different assets in different
// environments, specify an object as the first parameter. That
// object's keys should be the environment name and the values
// should be the asset to use in that environment.
//
// If the library that you are including contains AMD or ES6
// modules that you would like to import into your application
// please specify an object with the list of modules as keys
// along with the exports of each module as its value.

module.exports = app.toTree(fonts);
module.exports = app.toTree(images);
