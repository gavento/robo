define(function(require, exports, module) {

  function CSSSprite($el, x0, y0, dx, dy, dt, steps, reset, done_hook) {
    var x = x0;
    var y = y0;
    function clos() {
      if (steps > 0) {
        $el.css('background-position', ''+x+'px '+y+'px');
        steps -= 1;
        x += dx;
        y += dy;
        setTimeout(clos, dt);
      } else {
        if (reset) { $el.css('background-position', ''+x0+'px '+y0+'px'); }
        if (done_hook) { done_hook(); }
      }
    }
    clos();
  }

  module.exports = CSSSprite

});
