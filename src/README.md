RoboRace
========

A testing RoboRace javascript implementation.

Written mostly in [CoffeeScript](http://coffeescript.org/) (and compiled to JavaScript).
Using [RequireJS](http://requirejs.org/) for modularity,
[jQuery](http://jquery.com/) for DOM manipulation,
and [Spine](http://spinejs.com/) as the MVC framework.
The stylesheets are written in [Stylus](http://learnboost.github.com/stylus/) (compiled to CSS).
Also using [nodejs](http://nodejs.org/) and its npm for installing and running the development tools.


Installation
------------

1. Clone it: `git clone https://github.com/gavento/robo.git`.
2. Install `nodejs` and `npm` for development/release tools.
3. Install the dev tools by running `npm install` from the repo directory.

Running
-------

1. Compile the CSS and the release bundle using `make`
2. Start a local server by `make start`
3. Go to `http://0.0.0.0:4242/src/` to see the dev version (easier to debug)
4. Go to `http://0.0.0.0:4242/build/` to see the built version (which is faster)
5. Copy `build/` anywhere to publish.


---------

  Tomáš
