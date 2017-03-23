// var qs = require('querystring');

function generateObjects(pathname) {
  return {
    'err': {
      'description': null,
      'err': null,
      'from': null,
      'hashCode': null,
      'message': null,
      'statusCode': null,
      'statusText': null
    },
    'notification': {
      'from': null,
      'hashCode': null
    },
    'res': null,
    'req': {
      'body': null,
      'pathname': pathname
    },
    'user': null
  }
}

function parseQuery(body, callback) {
  if (!_.isObject(body)) {
    // body = qs.parse(body);

    try {
      // var _body = JSON.parse(_.keys(body)[0]);
      var _body = JSON.parse(body);

      if (_.isObject(_body)) {
        body = _body;
      }
    } catch (err) {
      if (!_.isObject(body)) {
        return callback(err, null);
      }
    }
  }

  return callback(null, body);
}

function start(db, handle, request, response, pathname, bodyGet, bodyPost, cb) {
  console.time(pathname);
  var info = generateObjects(pathname);

  async.parallel([
      parseQuery.bind(null, bodyGet),
      parseQuery.bind(null, bodyPost)
    ],function (err, result) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        info.err.description = 'Method: ' + request.method;
        info.err.err = err;
        info.err.from = 'parseQuery';
        info.err.statusCode = 400;

        return sendError(response, info);
      }

      bodyGet = result[0];
      bodyPost = result[1];

      if (request.method !== 'POST') {
        info.req.body = bodyGet;
        info.err.description = 'Method: ' + request.method;
        info.err.from = 'method';
        info.err.statusCode = 405;

        return sendError(response, info);
      }

      info.req.body = bodyPost;

      if (!_.isFunction(handle[info.req.pathname])) {
        info.err.description = 'Request handler is not found';
        info.err.from = 'handle';
        info.err.statusCode = 404;

        return sendError(response, info);
      }

      take(db, response, info, function (info) {
        return cb(info);
      });
    }
  )
}

function take(db, response, info, cb) {
  var _checkVar  = checkVar(info.req.body);

  if (!_.isNull(_checkVar)) {
    info.err.hashCode = _checkVar.hashCode;
    info.err.from = _checkVar.from;
    info.err.statusCode = 400;

    return sendError(response, info);
  }

  info.req.body = changeTypes(info.req.body);

  getUser(db, info, function(result) {
    if (!_.isNull(result.err)) {
      info.err.err = result.err;
      info.err.from = result.from;
      info.err.hashCode = result.hashCode;
      info.err.statusCode = result.statusCode;
      return sendError(response, info);
    }

    info.req.body = saveForces(info.req.body);
    info.user = result.user

    return cb(info);
  });
}

function checkVar(body) {
  var err = null

  if (!_.has(body, 'id')) {
    err = { 'hashCode': 0, 'from': 'checkVar #1' };
  }

  if (!_.isNull(err)) { return err; }

  if (!_.has(body, 'socialNetwork')) {
    err = { 'hashCode': 0, 'from': 'checkVar #2'};
  }

  return err;
}

function changeTypes(body) {
  body.id = Number(body.id);

  return body;
}

function getUser(db, info, cb) {
  result = { err: null, user: null };

  var users = db.collection('users');

  users.find({'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork}).toArray(function(err, found) {
    if (!_.isUndefined(err) && !_.isNull(err)) {
      result.err = {'statusCode': 500, 'hashCode': 1, 'from': 'getUser #1', 'err': err};
      return cb(result);
    }

    // если такого юзера в базе нет
    if (_.isEmpty(found)) {
      if (info.req.pathname === '/authorization') {
        return cb(result);
      }

      result.err = {'statusCode': 400, 'hashCode': 2, 'from': 'getUser #2', 'err': err};
      return cb(result);
    }

    // если юзеров много
    if (_.size(found) > 1) {
      result.err = {'statusCode': 500, 'hashCode': 3, 'from': 'getUser #3', 'err': err};
      return cb(result);
    }

    result.user = found[0];
    return cb(result);
  });
}

function saveForces(body) {
  if (_.has(body, 'forceEvilDiff')) {
    if (body.forceEvilDiff > 0) {
      if (body.socialNetwork !== 'test') {
        globalEvilNetwork += body.forceEvilDiff;
      }

      globalEvilAll += body.forceEvilDiff;
    }

    delete body.forceEvilDiff;
  }

  if (_.has(body, 'forceGoodDiff')) {
    if (body.forceGoodDiff > 0) {
      if (body.socialNetwork !== 'test') {
        globalGoodNetwork += body.forceGoodDiff;
      }

      globalGoodAll += body.forceGoodDiff;
    }

    delete body.forceGoodDiff;
  }

  return body;
}

function sendError(response, info) {
  switch(info.err.statusCode) {
    case 200:
      info.err.statusText = 'OK';
      break;
    case 400:
      info.err.statusText = 'Bad Request';
      break;
    case 404:
      info.err.statusText = 'Not found';
      break;
    case 405:
      info.err.statusText = 'Method Not Allowed. Allow: POST';
      break;
    case 500:
      info.err.statusText = 'Internal Server Error';
      break;
    default:
      info.err.statusText = null
  }

  switch(info.err.hashCode) {
    case 0:
      info.err.message = 'Увы, недостаточно данных...';
      break;
    case 1:
      info.err.message = 'Какая-то ошибка на сервере :(';
      break;
    case 2:
      info.err.message = 'Не нашла тебя в базе :(';
      break;
    case 3:
      info.err.message = 'Что-то странное, тебя несколько таких в базе ¯\\_(ツ)_/¯';
      break;
    default:
      info.err.message = null;
  }

  var text = 'Code: ' + info.err.statusCode + ' ' + info.err.statusText + '; Pathname: ' + info.req.pathname + '; Description: ' + info.err.description + '; From: ' + info.err.from + '; Body: ' + JSON.stringify(info.req.body) + '; Error: ' + info.err.err;

  console.error('Error! ' + text);

  fs.appendFile('/var/log/clickerTest.txt', text + '\n\n', function(err) {
    if (!_.isUndefined(err) && !_.isNull(err)) {
      console.log('Need TODO in validator! Err: ' + err);
    }
    response.writeHead(info.err.statusCode, {'Content-Type': 'application/json', 'charset': 'UTF-8', 'Access-Control-Allow-Origin': '*'});

    response.write(JSON.stringify({'err': info.err, 'res': info.res, 'req': info.req, 'user': info.user}));
    console.timeEnd(info.req.pathname);
    return response.end();
  });
}

function sendNotification(response, info) {
  switch(info.notification.hashCode) {
    case 0:
      info.notification.message = 'Тебе не хватает монет ;)';
      break;
    default:
      info.notification.message = null;
  }

  response.writeHead(200, {'Content-Type': 'application/json', 'charset':'UTF-8', 'Access-Control-Allow-Origin':'*'});
  response.write(JSON.stringify({'notification': info.notification}));
  console.timeEnd(info.req.pathname);
  return response.end();
}

exports.start            = start;

exports.sendError        = sendError;
exports.sendNotification = sendNotification;
