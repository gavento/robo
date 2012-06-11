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

function log(t) {
    $('#log').append('' + t + '\n');
}

/********************************
 * Tile types
 */

var tileTypesRepo = {}
function registerTileType(type, constructor) {
    tileTypesRepo[type] = constructor;
    constructor.prototype.type = type;
}

function Tile(tilerec) {
    this.img = null;
    this.type = '#';
    this.phases = [];
    this.zlevel = 0;
    this.drawDiv = function(div) {
	div.innerHTML = "";
	if (this.img) {
	    div.appendChild(this.img)
	}
    }
}


function GroundTile(tilerec) {
    goog.base(this);
    this.zlevel = 0;
    this.img = new Image();
    this.img.src = 'ground.png';
}
goog.inherits(GroundTile, Tile);
registerTileType('G', GroundTile);


function ConveyorTile(tilerec) {
    goog.base(this);
    this.dir = dirNum(tilerec.dir);
    this.img = new Image();
    this.img.src = 'conveyor-' + this.dir + '.png';
    this.zlevel = 10;
    this.phases = [20];
    this.activate = function(phase) {
	/* move any movable entity */
    }
}
goog.inherits(ConveyorTile, Tile);
registerTileType('C', ConveyorTile);


function HoleTile(tilerec) {
    goog.base(this);
    this.zlevel = 2;
    this.img = new Image();
    this.img.src = 'hole.png';
}
goog.inherits(HoleTile, Tile);
registerTileType('H', HoleTile);


/*******************************
 * Entity types
 */

var entityTypesRepo = {}
function registerEntityType(type, constructor) {
    entityTypesRepo[type] = constructor;
    constructor.prototype.type = type;
}

function Entity(tilerec) {
    this.img = null;
    this.type = '#';
    this.zlevel = 0;
    this.drawDiv = function(div) {
	div.innerHTML = "";
	if (this.img) {
	    div.appendChild(this.img)
	}
    }
    this.movable = function() {
	return true;
    }
}

function RobotEntity(rec) {
    goog.base(this);
    this.type = 'Robot';
    this.zlevel = 0;
    this.dir = 0;
    this.img = new Image();
    this.img.src = 'robo.png';
}
goog.inherits(GroundTile, Tile);
registerTileType('G', GroundTile);





function GameBoard(name) {
    /* [x,y] : [ Tiles ] */
    this.tiles = {};
    this.getTiles = function(x, y) {
	if (x < 0 || x >= this.w || y < 0 || y >= this.h)
	    return [ HoleTile() ];
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
    /* [x,y] : [ <div> ] */
    this.tableTiles = {};
    this.tableElements = {};
    /* rewrite the table */
    this.resetTable = function(table) {
	table.innerHTML = "";
	this.tableTd = {}
	this.tableElements = {}
	this.tableTiles = {}
	for (var y = 0; y < this.h; y++) {
	    var tr = table.insertRow(-1);
	    $(tr).addClass("gameBoard");
	    for (var x = 0; x < this.w; x++) {
		var td = tr.insertCell(-1);
		$(td).addClass("gameBoard");
		this.tableTd[[x,y]] = td;
		td.innerHTML = "<div class='gameBoardTiles'></div><div class='gameBoardEntities'></div>";
		this.tableTiles[[x,y]] = td.children[0];
		this.tableElements[[x,y]] = td.children[1];
	    }
	}
    }
    this.drawTable = function(table) {
	for (var x = 0; x < this.w; x++)
	    for (var y = 0; y < this.h; y++)
		this.drawTableTile(x, y)
    }
    this.drawTableTile = function(x, y) {
	log(""+x+y+this.tiles[[x,y]]);
	var tilesDiv = this.tableTiles[[x,y]];
	tilesDiv.innerHTML = "";
	var ts = this.tiles[[x, y]];
	ts.sort(function(a, b) {a.zlevel - b.zlevel});
	for (i in ts) {
	    var div = document.createElement("div");
	    $(div).addClass("gameBoardTile");
	    tilesDiv.appendChild(div);
	    ts[i].drawDiv(div);
	}
	this.tableElements[[x,y]].innerHTML = "";
    }
	

    /* JSON load */
    this.loadJSON = function(s) {
	var j = JSON.parse(s);
	this.name = j.name;
	this.w = j.width;
	this.h = j.height;
	var maxx = 0;
	for (x = 0; x < this.w; x++)
	    for (y = 0; y < this.h; y++)
	    	this.tiles[[x,y]] = [ new GroundTile() ]
	for (i in j.tiles) {
	    var t = j.tiles[i];
	    this.tiles[[t.x, t.y]].push(this.loadJSONTile(t));
	}
    }
    this.loadJSONTile = function(tile) {
	var type = tileTypesRepo[tile.t];
	if (type)
	    return new type(tile);
	log("Unknownt type '" + tile.t + "'");
	return undefined;
    }
}

$(document).ready(function() {
    log('Document ready ...');
    var b = new GameBoard();
    b.loadJSON(JSON.stringify({name: "Testik", width: 4, height: 3, tiles: [
	{ x: 0, y: 0, t: "H"},
	{ x: 1, y: 0, t: "C", dir: "E" },
	{ x: 2, y: 0, t: "C", dir: "S" },
	{ x: 2, y: 1, t: "C", dir: "S" },
	{ x: 1, y: 2, t: "H"},
	{ x: 2, y: 2, t: "H"}
    ], entities: [
	{ x: 1, y: 0, t: "Robot", dir: "S", player: "Player 1"},
	{ x: 3, y: 2, t: "Flag", number: 1}
    ]})); 
    log('Board ' + b.w + 'x' + b.h + ' loaded.');
    var t = $('#board0')[0];
    b.resetTable(t);
    b.drawTable(t);
});
