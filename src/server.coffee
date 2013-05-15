express = require 'express'
http = require 'http'
app = express()
server = http.createServer(app)
io = require('socket.io').listen(server)

# Read the port number from the commandline.
port = if process.argv.length > 2 then process.argv[2] else 80
server.listen(port)

# This serves the content of the top folder.
app.use express.static(__dirname + '/..')

# Some testing socket.io communication.
io.sockets.on 'connection', (socket) =>
  socket.on 'my other event', (data) =>
    console.log data
  socket.emit 'news', { hello: 'world' }
