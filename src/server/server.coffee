express = require 'express'
http = require 'http'
app = express()
server = http.createServer(app)
io = require('socket.io').listen(server)
stylus = require('stylus')

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
g = requirejs 'text!json/riddles/riddle_1.json'
game = Game.fromJSON(g)
game.bindEvent 'game:loaded', -> game.continue()
game.bindEvent 'state:entered', -> console.log game.state.current

app.use '/src', stylus.middleware
  src: __dirname + '/../style'
  dest: __dirname + '/../public'
app.use '/src', express.static(__dirname + '/../public')
app.use '/src/lib', express.static(__dirname + '/../lib')
app.use '/src/app', express.static(__dirname + '/../app')
app.use '/src/json', express.static(__dirname + '/../json')

app.use '/build', express.static(__dirname + '/../../build/public')
app.use '/build/lib', express.static(__dirname + '/../../build/lib')
app.use '/build/json', express.static(__dirname + '/../../build/json')

app.use '/test', express.static(__dirname + '/../../test')

# Some testing socket.io communication.
io.sockets.on 'connection', (socket) =>
  socket.on 'my other event', (data) =>
    console.log data
  socket.emit 'news', { hello: 'world' }
