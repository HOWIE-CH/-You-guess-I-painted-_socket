var express = require('express');
var app = express();

var formidable = require("formidable");
var fs = require('fs');
var path = require('path');

var http = require('http').Server(app);
var io = require('socket.io')(http);

//模板引擎
app.set("views", path.join(__dirname, "/views/"));
app.set("view engine", "ejs");
//静态服务
app.use(express.static(path.join(__dirname, "/public/")));
app.use("/upload", express.static(path.join(__dirname, "/upload/")));

// 主页
app.get('/', function (req, res, next) {
    res.render('index');
});
// 处理 ajax 表单提交
app.post('/', function (req, res, next) {
    // 使用 formidable 处理 post 请求
    var form = new formidable.IncomingForm();
    form.uploadDir = path.normalize(__dirname + "/upload/");
    form.parse(req, function (err, fields, files) {
        console.log(files);
        if (fields.image == "") {
            res.json({
                status: -1
            });
            return;
        }
        var oldpath = files.image.path;
        let randomNum = parseInt(Math.random()* 99999);
        var newpath = path.normalize(__dirname + "/upload/") + randomNum +  files.image.name ;
        fs.rename(oldpath, newpath, function (err) {
            if (err) {
                res.json({
                    status: 1
                });
                return;
            };
            res.json({
                // 将图片的名字回调给 inde.ejs
                status: randomNum +  files.image.name
            });
        });
    });
});


io.on('connection', function (socket) {
    console.log('one client connected');
    // 连接成功，自己给自己发个空的信息，回调下
    socket.emit('connection', null);
    // path
    socket.on('path', function (msg) {
        socket.broadcast.emit('path', msg);
    });
    // img
    socket.on('img', function (msg) {
        socket.broadcast.emit('img', msg);
    });
    // text
    socket.on('text', function (msg) {
        // 给出自己外的其他所有的 socket 广播
        socket.broadcast.emit('text', msg);
        // 给所有的 socket 的广播，包括自己
        // io.emit('text', msg);
    });
});

http.listen(5000, '127.0.0.1');
