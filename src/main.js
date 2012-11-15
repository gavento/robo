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
    "cs!app/menu",
    "cs!app/application"],
    function(Menu, App) {
  new Menu({el: "#header"});
  new App({el: "#app"});
});
