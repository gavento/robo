define (require, exports, module) ->

  # # Menu controller #
  class Menu extends Spine.Controller
    constructor: ->
      super
      
      @submenus = [
        new Submenu(1, "Robo", (-> @navigate("/")), []),
        new Submenu(1, "Editor", (-> @navigate("/edit/")), []),
        new Submenu(1, "Riddles", (-> @navigate("/riddles/")), [
          new Submenu(2, "1", (-> @navigate("/riddles/1")), []),
          new Submenu(2, "2", (-> @navigate("/riddles/2")), []),
          new Submenu(2, "3", (-> @navigate("/riddles/3")), []),
          new Submenu(2, "4", (-> @navigate("/riddles/4")), [])
          ])
        ]
      for s in @submenus
        @el.append s.el

  class Submenu extends Spine.Controller
    constructor: (@level, @name, @call, @submenus) ->
      super
      m = @$("<div class='MenuLevel#{ @level }'>#{ @name }</div>")
      m.click => @call()
      @el.append m
      for s in @submenus
        @el.append s.el
    
  module.exports = Menu
