var config = {
  baseUrl: '.',
  paths: {
    'cs' :'lib/cs',
    'text' :'lib/text',
    'coffee-script': 'lib/coffee-script',
  },
  shims: {
  }
};

require(config, [
    "cs!app/application"],
    function(App) {
  new App({el: "#app"});
});
