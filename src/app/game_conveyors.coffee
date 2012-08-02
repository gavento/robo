name: "Pasova desticka"
players: [
  {name: 'Alice', robotIds: ['Robot-1']},
  {name: 'Bob', robotIds: ['Robot-2', 'Robot-3']}
  {name: 'Cyril', robotIds: ['Robot-4']}
  ]
board:
  width: 8
  height: 8
  entities: [
    {type: 'C', dir: 'E', x: 0, y: 0},
    {type: 'C', dir: 'E', x: 1, y: 0},
    {type: 'C', dir: 'E', x: 2, y: 0},
    {type: 'C', dir: 'E', x: 3, y: 0},
    {type: 'C', dir: 'E', x: 4, y: 0},
    {type: 'C', dir: 'E', x: 5, y: 0},
    {type: 'C', dir: 'E', x: 6, y: 0},
    {type: 'E', dir: 'S', x: 7, y: 0},

    {type: 'E', dir: 'N', x: 0, y: 1},
    {type: 'E', dir: 'S', x: 1, y: 1},
    {type: 'E', dir: 'W', x: 2, y: 1},
    {type: 'C', dir: 'E', x: 3, y: 1},
    {type: 'E', dir: 'S', x: 4, y: 1},
    {type: 'E', dir: 'N', x: 5, y: 1},
    {type: 'C', dir: 'E', x: 6, y: 1},
    {type: 'E', dir: 'S', x: 7, y: 1},

    {type: 'E', dir: 'N', x: 0, y: 2},
    {type: 'C', dir: 'W', x: 1, y: 2},
    {type: 'E', dir: 'E', x: 2, y: 2},
    {type: 'E', dir: 'S', x: 3, y: 2},
    {type: 'C', dir: 'N', x: 4, y: 2},
    {type: 'E', dir: 'N', x: 5, y: 2},
    {type: 'E', dir: 'E', x: 6, y: 2},
    {type: 'E', dir: 'S', x: 7, y: 2},

    {type: 'E', dir: 'N', x: 0, y: 3},
    {type: 'C', dir: 'N', x: 1, y: 3},
    {type: 'C', dir: 'W', x: 2, y: 3},
    {type: 'C', dir: 'W', x: 3, y: 3},
    {type: 'C', dir: 'E', x: 4, y: 3},
    {type: 'C', dir: 'E', x: 5, y: 3},
    {type: 'E', dir: 'S', x: 6, y: 3},
    {type: 'E', dir: 'S', x: 7, y: 3},

    {type: 'E', dir: 'N', x: 0, y: 4},
    {type: 'C', dir: 'N', x: 1, y: 4},
    {type: 'C', dir: 'E', x: 2, y: 4},
    {type: 'C', dir: 'N', x: 3, y: 4},
    {type: 'E', dir: 'N', x: 4, y: 4},
    {type: 'E', dir: 'W', x: 5, y: 4},
    {type: 'C', dir: 'W', x: 6, y: 4},
    {type: 'E', dir: 'S', x: 7, y: 4},

    {type: 'E', dir: 'N', x: 0, y: 5},
    {type: 'E', dir: 'W', x: 1, y: 5},
    {type: 'C', dir: 'E', x: 2, y: 5},
    {type: 'E', dir: 'E', x: 3, y: 5},
    {type: 'E', dir: 'S', x: 4, y: 5},
    {type: 'C', dir: 'S', x: 5, y: 5},
    {type: 'C', dir: 'N', x: 6, y: 5},
    {type: 'E', dir: 'S', x: 7, y: 5},

    {type: 'E', dir: 'N', x: 0, y: 6},
    {type: 'C', dir: 'S', x: 1, y: 6},
    {type: 'C', dir: 'E', x: 2, y: 6},
    {type: 'E', dir: 'S', x: 3, y: 6},
    {type: 'C', dir: 'W', x: 4, y: 6},
    {type: 'E', dir: 'S', x: 5, y: 6},
    {type: 'C', dir: 'W', x: 6, y: 6},
    {type: 'E', dir: 'S', x: 7, y: 6},

    {type: 'E', dir: 'N', x: 0, y: 7},
    {type: 'C', dir: 'W', x: 1, y: 7},
    {type: 'C', dir: 'W', x: 2, y: 7},
    {type: 'C', dir: 'W', x: 3, y: 7},
    {type: 'C', dir: 'W', x: 4, y: 7},
    {type: 'C', dir: 'W', x: 5, y: 7},
    {type: 'C', dir: 'W', x: 6, y: 7},
    {type: 'C', dir: 'W', x: 7, y: 7},

    {type: 'Robot', dir: 'W', x: 2, y: 2, image:'roombo-r.png', id: 'Robot-1', health: 7, name: 'Cervenacek'},
    {type: 'Robot', dir: 'N', x: 2, y: 5, image:'roombo-g.png', id: 'Robot-2', health: 7, name: 'Zelenik'},
    {type: 'Robot', dir: 'S', x: 5, y: 4, image:'roombo-b.png', id: 'Robot-3', health: 7, name: 'Modracek'},
    {type: 'Robot', dir: 'S', x: 4, y: 0, image:'roombo-y.png', id: 'Robot-4', health: 7, name: 'Zlutasek'},
    {type: 'Robot', dir: 'E', x: 4, y: 1, image:'roombo-m.png', id: 'Robot-5', health: 7, name: 'Fialka'},
  ]

