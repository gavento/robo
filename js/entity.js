/*******************************
 * Entity types
 */


var entityTypesRepo = {}
function registerEntityType(type, constructor) {
    entityTypesRepo[type] = constructor;
    constructor.prototype.type = type;
}


function Entity(par) {
    this.x = getDefault(par, "x", 0);
    this.y = getDefault(par, "y", 0);
    this.board = getDefault(par, "board", undefined);
    this.img = null;
    this.type = '#';
    this.zlevel = 0;
    this.boardPhases = [];
    this.drawDiv = function(div) {
	if (this.img) {
	    div.appendChild(this.img)
	}
    }
    this.movable = function() {
	return true;
    }
    /* activate in board phases */
    this.boardActivate = function(board, phase) {
    }
    this.clone = function() {
	return jQuery.extend({}, this);
    }
}


function Tile(par) {
    goog.base(this, par);
    this.movable = function() {
	return false;
    }
}
goog.inherits(Tile, Entity);


function Conveyor(par) {
    goog.base(this, par);
    this.dir = Dir.toDir(getDefault(par, "dir", 0));
    this.img = new Image();
    this.img.src = 'i/conveyor-' + this.dir + '.png';
    this.zlevel = 10;
    this.boardPhases = [20];
    this.activate = function(phase) {
	self = this;
	this.board.tiles[[this.x, this.y]].forEach(function(e) {
	    if (e.movable())
		self.board.schedulePush(e, self.dir);
	})
    }
}
goog.inherits(Conveyor, Tile);
registerEntityType('C', Conveyor);


function ExpressConveyor(par) {
    goog.base(this, par);
    this.img = new Image();
    this.img.src = 'i/express-conveyor-' + this.dir + '.png';
    this.zlevel = 10;
    this.boardPhases = [19, 21];
}
goog.inherits(ExpressConveyor, Conveyor);
registerEntityType('E', ExpressConveyor);


function Turner(par) {
    goog.base(this, par);
    this.dir = getDefault(par, "dir", 2);
    this.img = new Image();
    this.imgnames = { 1: "R", 2: "U"};
    this.imgnames[-1] = "L";
    this.img.src = 'i/turner-' + this.imgnames[this.dir] + '.png';
    this.zlevel = 10;
    this.boardPhases = [25];
    this.activate = function(phase) {
	self = this;
	this.board.tiles[[this.x, this.y]].forEach(function(e) {
	    if (e instanceof Robot && e.movable())
		e.dir = Dir.toDir(e.dir + self.dir);
	})
    }
}
goog.inherits(Turner, Tile);
registerEntityType('T', Turner);


function Hole(par) {
    goog.base(this, par);
    this.zlevel = 0;
    this.img = new Image();
    this.img.src = 'i/hole.png';
}
goog.inherits(Hole, Tile);
registerEntityType('H', Hole);

function Crusher(par) {
    goog.base(this, par);
    this.zlevel = 200;
    this.img = new Image();
    this.img.src = 'i/crusher.png';
    this.boardPhases = [30];
    this.activate = function(phase) {
	var tile = this.board.tiles[[this.x, this.y]];
	for (i in tile) {
	    var e = tile[i];
	    if (e instanceof Robot)
		e.damage(1);
	}
    }
}
goog.inherits(Crusher, Tile);
registerEntityType('X', Crusher);


function Robot(par) {
    goog.base(this, par);
    this.zlevel = 50;
    this.dir = Dir.toDir(getDefault(par, "dir", 0));
    this.player = getDefault(par, "player", "unknown");
    this.imgs = {}
    for (var d = 0; d < 4; d++) {
	this.imgs[d] = new Image();
	this.imgs[d].src = 'i/robo-'+d+'.png';
    }
    this.drawDiv = function(div) {
	div.appendChild(this.imgs[this.dir])
    }
    this.damage = function(damage) {
	log("Robot "+this.player+" took "+damage+" damage.");
    }
}
goog.inherits(Robot, Entity);
registerEntityType('Robot', Robot);


function Flag(par) {
    goog.base(this, par);
    this.type = 'Flag';
    this.zlevel = 100;
    this.number = getDefault(par, "number", 0);
    this.drawDiv = function(div) {
	div.innerHTML = "<span class='flag'>" + this.number + "</span>";
    }
}
goog.inherits(Flag, Entity);
registerEntityType('Flag', Flag);

