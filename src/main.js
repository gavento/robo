var config = {
  baseUrl: '.',
  paths: {
    'cs' :'lib/cs',
    'coffee-script': 'lib/coffee-script',
//    'jquery': 'lib/jquery-1.7.2',
//    'spine': 'lib/spine',
  },
  shims: {
//    'lib/spine': {
//      deps: ['jquery'],
//      exports: 'Spine',
//    }
  }
};

require(config, [
    "cs!app/application"],
    function(App) {
  new App({el: "#app"});
});
