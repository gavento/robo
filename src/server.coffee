express = require 'express'
http = require 'http'
app = express()
server = http.createServer(app)
io = require('socket.io').listen(server)

# Read the port number from the commandline.
port = if process.argv.length > 2 then process.argv[2] else 80
server.listen(port)

requirejs = require 'requirejs'
config = {
  baseUrl: './src'
  paths: {
    'cs' : 'lib/cs'
    'text' :'lib/text'
    'coffee-script': 'lib/coffee-script'
  }
}
requirejs config
Game = requirejs 'cs!app/models/Game'
g = requirejs 'text!app/riddles/riddle_1.json'
game = Game.fromJSON(g)
game.bindEvent 'game:loaded', -> game.continue()
game.bindEvent 'state:entered', -> console.log game.state.current

# This serves the content of the top folder.
app.use express.static(__dirname + '/..')

# Some testing socket.io communication.
io.sockets.on 'connection', (socket) =>
  socket.on 'my other event', (data) =>
    console.log data
  socket.emit 'news', { hello: 'world' }
