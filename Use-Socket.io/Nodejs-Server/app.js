const express = require('express');
const app = express();

const http = require('http').Server(app);
const io = require('socket.io')(http);


app.get('/', (req, res, next) =>{
    res.send('hello world');
});


io.on('connection', (socket) => {
    console.log('one client connection');
    
    socket.emit('connection', null);

    // path
    socket.on('path', (msg) => {
        socket.broadcast.emit('path', msg);
    });
    // img
    socket.on('img', (msg) => {
        socket.broadcast.emit('img', msg);
    });
    // text
    socket.on('text', (msg) => {
        socket.broadcast.emit('text', msg);
    });
})
// http.listen(5000, '127.0.0.1');
// http.listen(5000, '192.168.1.19');
http.listen(5000, '192.168.1.111');
