({
    appDir: 'src',
    baseUrl: '.',
    mainConfigFile: './src/main.js',
    
	//Uncomment to turn off uglify minification.
    optimize: 'none',
    dir: 'build/',

    //Stub out the cs module after a build since
    //it will not be needed.
    stubModules: ['cs'],

//    paths: {
//        'cs' :'lib/cs',
//        'coffee-script': 'lib/coffee-script',
//        'text': 'lib/text',
//	'jquery': 'lib/jquery-1.7.2',
//	'spine': 'lib/spine',
//    },

/*    shims: {
      'spine': {
	deps: ['jquery'],
        exports: 'Spine',
      }
    },
*/
    pragmasOnSave: {
      excludeCoffeeScript: true
    },

    modules: [
        {
            name: 'main',
            //The optimization will load CoffeeScript to convert
            //the CoffeeScript files to plain JS. Use the exclude
            //directive so that the coffee-script module is not included
            //in the built file.
            exclude: ['coffee-script']
        }
    ]
})
