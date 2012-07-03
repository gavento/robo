/******************************
 * Experiments
 */

var b;
var turn = 0;
var gameHistory = [];

function showBoard(board) {
    var t = $('#board0')[0];
    board.resetTable(t);
    board.drawTable(t);
}

function activateBoard() {
    $('#log').append('<div class="showHistory" onmouseover="showBoard(gameHistory['+turn+'])" onmouseout="showBoard(b)">' +
        'Turn '+turn+' (shows gameHistory)</div>');
    gameHistory.push(b.clone());
    turn++;
    b.activateBoard();
    showBoard(b);
}

$(document).ready(function() {
    $('#activate').click(activateBoard);
    log('Document ready ...');
    b = new GameBoard();
    b.loadJSON(JSON.stringify({name: "Testik", width: 6, height: 4, tiles: [
	{ x: 2, y: 1, t: "X"},
	{ x: 0, y: 1, t: "H"},
	{ x: 1, y: 1, t: "H"},
	{ x: 1, y: 0, t: "C", dir: "E" },
	{ x: 2, y: 0, t: "E", dir: "S" },
	{ x: 2, y: 1, t: "E", dir: "S" },
	{ x: 2, y: 2, t: "E", dir: "S" },
	{ x: 1, y: 2, t: "H"},
	{ x: 2, y: 3, t: "T", dir: 1},
	{ x: 2, y: 3, t: "Flag", number: 0},
	{ x: 1, y: 0, t: "Robot", dir: "S", player: "Player 1"},

	{ x: 5, y: 0, t: "C", dir: "W" },
	{ x: 4, y: 0, t: "C", dir: "W" },
	{ x: 3, y: 0, t: "C", dir: "S" },
	{ x: 3, y: 1, t: "C", dir: "E" },
	{ x: 4, y: 1, t: "C", dir: "E" },
	{ x: 5, y: 1, t: "C", dir: "N" },
	{ x: 5, y: 0, t: "Flag", number: 1},
	{ x: 3, y: 1, t: "Robot", dir: "N", player: "Player 1.5"},

	{ x: 0, y: 2, t: "C", dir: "S" },
	{ x: 0, y: 3, t: "T", dir: 2},
	{ x: 0, y: 3, t: "X"},
	{ x: 0, y: 2, t: "Robot", dir: "W", player: "Player 2"},

	{ x: 3, y: 3, t: "E", dir: "E" },
	{ x: 4, y: 3, t: "C", dir: "E" },
	{ x: 5, y: 3, t: "T", dir: -1},
	{ x: 3, y: 3, t: "Robot", dir: "E", player: "Player 3"}

    ]}));
    log('Board ' + b.w + 'x' + b.h + ' loaded.');
    var t = $('#board0')[0];
    b.resetTable(t);
    b.drawTable(t);

    var c = [];
    c.push(new SimpleCard('S R', 106, 'SR'));
    c.push(new SimpleCard('3xS', 301, 'SSS'));
    c.push(new SimpleCard('2xS', 202, 'SS'));
    c.push(new SimpleCard('L 2xS', 208, 'LSS'));
    c.push(new SimpleCard('U', 42, 'U'));
    c.push(new SimpleCard('R', 18, 'R'));
    c.push(new SimpleCard('L', 43, 'L'));
    c.sort(function(a,b){return b.priority - a.priority});
    _(c).each(function(card) {
	$('.card-pool').append(card.e);
	$(card.e).draggable({revert: "invalid"});
	});
    $('.card-plan-slot').each(function($e) {
	$(this).droppable({ drop: function(event, ui) { planCard(ui.draggable, $(this)); } });
    });
    $('.card-pool').disableSelection();
    $('.card-pool').droppable({ drop: function(event, ui) { unplanCard(ui.draggable); } });
});

function unplanCard($card) {
  $card.appendTo(".card-pool");
  $card.css('left', 0);
  $card.css('top', 0);
}

function planCard($card, $slot) {
  var $planned = $slot.children('.card-face');
  if ($planned.length > 0)
    unplanCard($planned)
  $card.appendTo($slot);
  $card.css('left', 0);
  $card.css('top', 0);
}

function Card(text, priority) {
    this.text = text;
    this.priority = priority;
    this.e = $('<div class="card-face"><i>' + priority + '</i><br>' + text + '</div>');
    this.execute = function(robot) {
	log("Playing card " + this.text + " on " + robot);
    }
}

/* Commands are given as a character sequence: 
 * S - step
 * J - jump (not really implemented)
 * L - turn left
 * R - turn right
 * U - U-turn
 */
function SimpleCard(text, priority, commands) {
    goog.base(this, text, priority);
    this.commands = commands;
    this.execute = function(robot) {
	goog.base(this, 'execute', robot);
	_.each(this.commands, function(c) {
	    log("Executing command " + c + " on " + robot);
	    cmds = { S: robot.step,
		     J: robot.jump,
		     L: robot.turnLeft,
		     R: robot.turnRight,
		     U: robot.uTurn };
	    if (cmds[s])
		cmds[c].call(robot);
	    else
		throw ("Invalid command " + c);
	});
    }
}
goog.inherits(SimpleCard, Card);

