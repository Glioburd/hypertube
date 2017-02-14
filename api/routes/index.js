var express = require('express');
var router = express.Router();
var torrentStream = require('torrent-stream');
var mysql = require("mysql");
var fs = require('fs');
var ffmpeg = require('fluent-ffmpeg');
var con = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: 'hypertube_dev'
});
var home = process.env.HOME + '/goinfre/hypertube/public';
router.get('/download', function(req, res, next) {
  magnet = req.query.magnet;
  id = req.query.id;
  var engine = torrentStream(magnet, {
    path: home + '/videos/' + id
  });
  engine.on('ready', function() {
    console.log('ready');
    var Filesmovie = engine.files.filter(function(file){
      if (file.name.split('.').slice(-1)[0] == "mkv" || file.name.split('.').slice(-1)[0] == "ogg"  || file.name.split('.').slice(-1)[0] == "avi" || file.name.split('.').slice(-1)[0] == "mp4" || file.name.split('.').slice(-1)[0] == "webm") {
        return true;
      }
    });
    var file = Filesmovie[0];
    if (file && file != "undefined") {
      var format = Filesmovie[0].name.split('.').slice(-1)[0];
      var stream = file.createReadStream();
      ffmpeg()
        .input(stream)
        .outputOptions(
          '-c:v', 'libx264',
          '-acodec', 'copy',
          '-f', 'segment',
          '-map', 0,
          '-segment_list', home + '/videos/' + id + '/playlist.m3u8',
          '-segment_list_flags', '+live',
          '-segment_time', 10)
        .output(home + '/videos/' + id + '/out%03d.ts')
        .on('error', function(err) {
          console.log('An error occurred: ' + err.message);
        })
        .on('end', function() {
          console.log('Copy finish');
        })
        .run();
      stream.on('error', function(err) {
        console.log('Stream error', err);
        res.end(err);
      });

      stream.on('end', function() {
        console.log('Stream ended');
      });

      stream.on('close', function() {
        console.log('Stream closed');
      });

      stream.on('data', function(buffer) {
        console.log('Got data from torrent stream', buffer.length);
      });
      setTimeout(function(){
        res.json({'ok': 1, 'path': file.path});
      }, 40000);
    }
    else {
      if (engine.files[1]) {
        folder = home + '/' + engine.files[0].path.split('/')[0]
        engine.destroy();
        fs.rmdir(folder, function (err) {
          res.json({'ok': 0});
        })
      }
      else {
        file = home + '/' + engine.files[0].path
        engine.destroy();
        fs.unlink(file);
        res.json({'ok': 0});
      }
    }
    var check = 0;
    engine.on('download', function(pieceIndex, buffer) {
      console.log('Piece downloaded with index: ', pieceIndex);
    });
  });
});

module.exports = router;  