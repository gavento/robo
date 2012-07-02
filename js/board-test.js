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
    log('<span class="showHistory" onmouseover="showBoard(gameHistory['+turn+'])" onmouseout="showBoard(b)">' +
        'Turn '+turn+' (shows gameHistory)');
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
});

