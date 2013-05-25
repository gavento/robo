require.config({
  baseUrl: '.',
  paths: {
    'cs' :'lib/cs',
    'text' :'lib/text',
    'coffee-script': 'lib/coffee-script',
    'spine' : 'spine-shim',
    'async' : 'async-shim',
    'underscore' : 'underscore-shim',
  },
  shims: {
  }
});

require([
    "cs!app/menu",
    "cs!app/application"],
    function(Menu, App) {
  new Menu({el: "#header"});
  new App({el: "#app"});
});
