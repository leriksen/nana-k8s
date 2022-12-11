'use strict';
const http = require('http');
const util = require('util');

const server = http.createServer((req, res) => {
  console.log("received request for " + req.url);

  res.setHeader('Content-Type', 'application/json');
  res.write(util.format('%j', req.headers))
  res.end();
});
server.on('clientError', (err, socket) => {
  socket.end('HTTP/1.1 400 Bad Request\r\n\r\n');
});
server.listen(80);

console.log("Running on http://0.0.0.0:80");
