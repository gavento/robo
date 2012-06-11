/* directions:
 *   0
 *  3 1
 *   2
 */

function dirNum(dir) {
    switch (dir) {
    case 'N':
    case 0:
	return 0;
    case 'E':
    case 1:
	return 1;
    case 'S':
    case 2:
	return 2;
    case 'W':
    case 3:
	return 3;
    }
    return 0;
}

function getDefault(obj, attribute, val) {
    if (obj == undefined || obj[attribute] == undefined)
	return val;
    return obj[attribute];
}

function log(t) {
    $('#log').append('' + t + '\n');
}

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
    this.dir = dirNum(getDefault(par, "dir", 0));
    this.img = new Image();
    this.img.src = 'i/conveyor-' + this.dir + '.png';
    this.zlevel = 10;
    this.phases = [20];
    this.activate = function(phase) {
	var tile = board.tiles[[this.x, this.y]];
	for (i in tile) {
	    var e = tile[i];
//	    if (e.movable())
//		e.schedulePush(this.dir);
	}
    }
}
goog.inherits(Conveyor, Tile);
registerEntityType('C', Conveyor);

function ExpressConveyor(par) {
    goog.base(this, par);
    this.img = new Image();
    this.img.src = 'i/express-conveyor-' + this.dir + '.png';
    this.zlevel = 10;
    this.phases = [19, 21];
}
goog.inherits(ExpressConveyor, Conveyor);
registerEntityType('E', ExpressConveyor);

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
    this.zlevel = 0;
    this.img = new Image();
    this.img.src = 'i/crusher.png';
}
goog.inherits(Hole, Tile);
registerEntityType('H', Hole);

function Robot(par) {
    goog.base(this, par);
    this.zlevel = 50;
    this.dir = dirNum(getDefault(par, "dir", 0));
    this.imgs = {}
    for (var dir = 0; dir < 4; dir++) {
	this.imgs[dir] = new Image();
	this.imgs[dir].src = 'i/robo-'+dir+'.png';
    }
    this.drawDiv = function(div) {
	div.appendChild(this.imgs[this.dir])
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


/********************************
 * Game board
 */

function GameBoard(name) {
    /* [x,y] : [ Entities ] */
    this.tiles = {};
    this.getTiles = function(x, y) {
	if (x < 0 || x >= this.w || y < 0 || y >= this.h)
	    return [ Hole() ];
	return this.tiles[[x, y]];
    }
    /* all coordinates within 0..w-1, 0..h-1 */
    this.w = 1;
    this.h = 1;
    /* string name */
    this.name = name;

    /* viewing as table */
    /* [x,y] : <td> */
    this.tableTd = {};
    /* rewrite the table */
    this.resetTable = function(table) {
	table.innerHTML = "";
	this.tableTd = {}
	for (var y = 0; y < this.h; y++) {
	    var tr = table.insertRow(-1);
	    $(tr).addClass("gameBoard");
	    for (var x = 0; x < this.w; x++) {
		var td = tr.insertCell(-1);
		$(td).addClass("gameBoard");
		this.tableTd[[x,y]] = td;
	    }
	}
    }
    this.drawTable = function(table) {
	for (var x = 0; x < this.w; x++)
	    for (var y = 0; y < this.h; y++)
		this.drawTableTile(x, y)
    }
    this.drawTableTile = function(x, y) {
	var div = this.tableTd[[x,y]];
	div.innerHTML = "";
	var ts = this.tiles[[x, y]];
	ts.sort(function(a, b) {return a.zlevel - b.zlevel});
	for (i in ts) {
	    var ediv = document.createElement("div");
	    $(ediv).addClass("gameBoardEntity");
	    div.appendChild(ediv);
	    ts[i].drawDiv(ediv);
	}
    }

    /* JSON load */
    this.loadJSON = function(s) {
	var j = JSON.parse(s);
	this.name = j.name;
	this.w = j.width;
	this.h = j.height;
	for (x = 0; x < this.w; x++)
	    for (y = 0; y < this.h; y++)
		this.tiles[[x,y]] = [];
	for (i in j.tiles) {
	    var e = j.tiles[i];
	    this.tiles[[e.x, e.y]].push(this.loadJSONEntity(e));
	}
    }
    this.loadJSONEntity = function(ent) {
	var type = entityTypesRepo[ent.t];
	if (type)
	    return new type(ent);
	log("Unknownt entity type '" + ent.t + "'");
	return undefined;
    }
}

$(document).ready(function() {
    log('Document ready ...');
    var b = new GameBoard();
    b.loadJSON(JSON.stringify({name: "Testik", width: 6, height: 3, tiles: [
	{ x: 0, y: 0, t: "H"},
	{ x: 1, y: 0, t: "C", dir: "E" },
	{ x: 2, y: 0, t: "E", dir: "S" },
	{ x: 2, y: 1, t: "E", dir: "S" },
	{ x: 1, y: 2, t: "H"},
	{ x: 2, y: 2, t: "H"},
	{ x: 1, y: 0, t: "Robot", dir: "S", player: "Player 1"},

	{ x: 5, y: 0, t: "Flag", number: 1},
	{ x: 5, y: 0, t: "C", dir: "W" },
	{ x: 4, y: 0, t: "C", dir: "S" },
	{ x: 4, y: 1, t: "C", dir: "E" },
	{ x: 5, y: 1, t: "C", dir: "N" }
    ]})); 
    log('Board ' + b.w + 'x' + b.h + ' loaded.');
    var t = $('#board0')[0];
    b.resetTable(t);
    b.drawTable(t);
});
