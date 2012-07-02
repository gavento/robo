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
    /* scheduled pushes, WIP */
    this.pushes = [];

    this.clone = function() {
	var b = new GameBoard(this.name);
	b.w = this.w;
	b.h = this.h;
	for (var x = 0; x < this.w; x++)
	    for (var y = 0; y < this.h; y++) {
		b.tiles[[x, y]] = [];
		this.tiles[[x, y]].forEach(function(e){
		    b.tiles[[x, y]].push(e.clone());
		})
	    }
	return b;
    }

    this.activateBoard = function() {
	byPhase = {}
	for (var x = 0; x < this.w; x++)
	    for (var y = 0; y < this.h; y++) {
		this.tiles[[x, y]].forEach(function(e) {
		    e.boardPhases.forEach(function(phase) {
			byPhase[phase] = getDefault(byPhase, phase, []);
			byPhase[phase].push(e); 
		    })
		})
	    }
	var phases = Object.keys(byPhase);
	phases.sort();
	var self = this;
	phases.forEach(function(phase) {
	    byPhase[phase].forEach(function(e) {
		e.activate(phase);
	    })
	    self.resolvePushes();
	})
    }

    /* Think this through! */
    this.schedulePush = function(what, dir) {
	this.pushes.push([what,dir]);
    }
    this.resolvePushes = function() {
	self = this;
	this.pushes.forEach(function(push) {
	    var e = push[0];
//	    log("Push from "+e.x+","+e.y+" in dir "+push[1]);
	    var t = self.tiles[[e.x, e.y]];
	    var i = t.indexOf(e);
	    t.splice(i, 1);
	    e.x += Dir.DX[push[1]];
	    e.y += Dir.DY[push[1]];
	    self.tiles[[e.x, e.y]].push(e);
	})
	this.pushes = [];
    }


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
	if (type) {
	    ent.board = this;
	    return new type(ent);
	}
	log("Unknownt entity type '" + ent.t + "'");
	return undefined;
    }
}
