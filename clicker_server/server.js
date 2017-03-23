// var http = require("http");
var https = require("https");
var url = require("url");

var options = {
  key : fs.readFileSync('/etc/ssl/private/clickerTest.key'),
  cert: fs.readFileSync('/etc/ssl/certs/clickerTest.crt')
};

function start(db, route, handle) {
  function onRequest(request, response) {
    var pathname = url.parse(request.url).pathname
    var bodyGet  = url.parse(request.url).query;
    var bodyPost = '';

    request.on('data', function (data) {
      bodyPost += data;

      if (bodyPost.length > 1e6) {
        console.log('Data is very long:', err);
        return request.connection.destroy();
      }
    });

    request.on('end', function () {
      return route(db, handle, request, response, pathname, bodyGet, bodyPost);
    });
  }

  // http.createServer(onRequest).listen(20001, "192.168.1.150");
  https.createServer(options, onRequest).listen(20001, "192.168.1.150");
  console.log("Server has started.");
}

exports.start = start;
