/*
 * Module Dir
 *
 * Convert dir to direction from (0,1,2,3)
 * Accepts numbers (mod 4) and 'SENW'
 */

/* 
 * Main directions:
 *   0
 *
 * 3 X 1
 *   
 *   2
 */

var Dir = {};

Dir.DX = [0, +1, 0, -1];
Dir.DY = [-1, 0, +1, 0];

Dir.nameToDir = {"N": 0, "E": 1, "S": 2, "W": 3};
Dir.dirToName = {0: 'N', 1: 'E', 2: 'S', 3: 'W'};

Dir.toDir = function (d) {
    if (typeof(d) == 'number')
      return (Math.round(d % 4) + 4) % 4;
    if (typeof(Dir.nameToDir[d]) == 'number')
      return Dir.nameToDir[d];
    throw "Invalid direction specification";
}


/*
 * Default parameters
 */

function getDefault(obj, attribute, val) {
    if (obj == undefined || obj[attribute] == undefined)
	return val;
    return obj[attribute];
}

/*
 * Logging
 */

function log() {
    console.log.apply(console, arguments);
}
