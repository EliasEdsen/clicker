var validator = require('./validator.js');

function route(db, handle, request, response, pathname, bodyGet, bodyPost) {
  validator.start(db, handle, request, response, pathname, bodyGet, bodyPost, function(info) {
    handle[info.req.pathname](db, info, response);
  });
}

exports.route = route;
