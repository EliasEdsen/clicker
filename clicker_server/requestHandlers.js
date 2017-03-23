var xml = require('xmlhttprequest').XMLHttpRequest;
var validator = require('./validator.js');

function dateNow() {
  var d = Date.now() / 1000;
  d = Number( d.toFixed(0) );

  return d;
}

function getInformation(db, callback) {
  db.collection('information').findOne({}, function(err, found) {
    if (!_.isUndefined(err) && !_.isNull(err)) {
      return callback({'from': '/getInformation #1', 'err': err}, null);
    }

    if (_.isEmpty(found)) {
      return callback({'from': '/getInformation #2', 'err': null}, null);
    }

    return callback(null, found);
  });
}

function authorization(db, info, response) {
  async.parallel([
    getInfo,
    getUser,
    getFriends
    ],function (err, result) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        if (!_.isObject(err)) { var err = {}; }
        if (!_.has(err, 'err')) { err.err = null; }
        if (!_.has(err, 'from')) { err.from = '/authorization #1'; }
        else { err.from = '/authorization #2 -> ' + from; }
        info.err.err = err.err;
        info.err.from = err.from;
        info.err.hashCode = 1;
        info.err.statusCode = 500;
        return validator.sendError(response, info);
      }

      info.res = result;

      return callResponse(response, info);
    }
  );

  function getInfo(callback) {
    return getInformation(db, callback);
  }

  function getUser(callback) {
    // если такого юзера в базе нет
    if (_.isNull(info.user)) {
      db.collection('users').insert({
        'id'            : info.req.body.id,     // TODO нужна проверка на существование, в валидатор
        'firstName'     : info.req.body.firstName,     // TODO нужна проверка на существование, в валидатор
        'lastName'      : info.req.body.lastName,     // TODO нужна проверка на существование, в валидатор
        'photo100'      : info.req.body.photo100,     // TODO нужна проверка на существование, в валидатор
        'socialNetwork' : info.req.body.socialNetwork,     // TODO нужна проверка на существование, в валидатор

        'exp'       : 0,
        'totalExp'  : 0,
        'level'     : 1,
        'countClick': 0,

        'forceEvil': 0,
        'forceGood': 0,

        'timeForEvil': 0,
        'timeForGood': 0,

        'playerDoubleStr': 1,
        'botDoubleStr'   : 1,
        'botDoubleSpeed' : 1,

        'playerDoubleStrWasUsed': 0,
        'botDoubleStrWasUsed'   : 0,
        'botDoubleSpeedWasUsed' : 0,

        'thingsCommon': {'0': true},
        'thingsEvil'  : {},
        'thingsGood'  : {},

        'thingsAtPlayer': [{'force': 'common', 'num': 0, 'name': 'face', 'status': 3}],

        'botCommon': {'1': 1},
        'botEvil'  : {},
        'botGood'  : {},

        'coins': 100,

        'lastEveryday' : dateNow() - (1 * 60 * 60 * 24 * 1),
        'achievments'  : {},

        'reset'         : [],
        'saveDate'      : null,
        'music'         : 50,
        'sound'         : 50
      }, function(err, inserted) {
        if (!_.isUndefined(err) && !_.isNull(err)) {
          return callback({'from': '/getUser #1', 'err': err}, null);
        }

        return callback(null, inserted.ops[0]);
      });

    // если юзер найден
    } else {
      // перезаписываем поля в базу
      db.collection('users').findAndModify(
        {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
        [],
        {$set: {'firstName': info.req.body.firstName, 'lastName': info.req.body.lastName, 'photo100': info.req.body.photo100}},
        {new: true},
        function(err, modifed) {
          if (!_.isUndefined(err) && !_.isNull(err)) { return callback({'from': '/getUser #2', err: err}, null); }

          return callback(null, modifed.value);
        }
      );
    }
  }

  function getFriends(callback) {
    var friends = {};
    friends.friendsPlay = {};
    friends.friendsNotPlay = _.clone(info.req.body.friendsAllId);

    db.collection('users').find({'id':{ $in : info.req.body.friendsAllId }, 'socialNetwork': info.req.body.socialNetwork}).toArray(function(err, result) {
      if (!_.isUndefined(err) && !_.isNull(err)) { return callback({'from': '/getFriends #1', 'err': err}, null); }

      for (var key in result) {
        friends.friendsPlay[key]           = {};
        friends.friendsPlay[key].id        = result[key].id;
        friends.friendsPlay[key].firstName = result[key].firstName;
        friends.friendsPlay[key].lastName  = result[key].lastName;
        friends.friendsPlay[key].photo100  = result[key].photo100;
        friends.friendsPlay[key].exp       = result[key].exp;
        friends.friendsPlay[key].level     = result[key].level;
        friends.friendsPlay[key].forceEvil = result[key].forceEvil;
        friends.friendsPlay[key].forceGood = result[key].forceGood;

        friends.friendsNotPlay.splice( friends.friendsNotPlay.indexOf( friends.friendsPlay[key].id ), 1 );
      }

      return callback(null, friends);
    });
  }
}

function resetUser(db, info, response) {
  db.collection('users').update({'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork}, {
    $set: {
      'exp'                   : 0,
      'totalExp'              : 0,
      'level'                 : 1,
      'countClick'            : 0,
      'forceEvil'             : 0,
      'forceGood'             : 0,
      'timeForEvil'           : 0,
      'timeForGood'           : 0,
      'playerDoubleStr'       : 1,
      'botDoubleStr'          : 1,
      'botDoubleSpeed'        : 1,
      'playerDoubleStrWasUsed': 0,
      'botDoubleStrWasUsed'   : 0,
      'botDoubleSpeedWasUsed' : 0,
      'thingsCommon'          : {'0': true},
      'thingsEvil'            : {},
      'thingsGood'            : {},
      'thingsAtPlayer'        : [{'force': 'common', 'num': 0, 'name': 'face', 'status': 3}],
      'botCommon'             : {'1': 1},
      'botEvil'               : {},
      'botGood'               : {},
      'coins'                 : 100,
      'achievments'           : {},
      'lastEveryday'          : dateNow() - (1 * 60 * 60 * 24 * 1),
      'saveDate'              : null
    },
    $push: {
      'reset': dateNow()
    }
  }, function(err, updated) {
    if (!_.isUndefined(err) && !_.isNull(err)) {
      info.err.err = err;
      info.err.from = '/resetUser #1';
      info.err.hashCode = 1;
      info.err.statusCode = 500;

      return validator.sendError(response, info);
    }

    return callResponse(response, info);
  });
}

function save(db, info, response) {
  db.collection('users').findAndModify(
    {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
    [],
    {$set : info.req.body},
    {new: true},
    function(err, modifed) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        info.err.err = err;
        info.err.from = '/save #1';
        info.err.hashCode = 1;
        info.err.statusCode = 500;

        return validator.sendError(response, info);
      }

      return callResponse(response, info);
    }
  );
}

function pickAchievement(db, info, response) {
  info.user.coins += info.req.body.coins;
  info.user.achievments[info.req.body.name] = info.req.body.key + 1;

  db.collection('users').findAndModify(
    {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
    [],
    {$set : {
      'coins'      : info.user.coins,
      'achievments': info.user.achievments
    }},
    {new: true},
    function(err, modifed) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        info.err.err = err;
        info.err.from = '/pickAchievement #1';
        info.err.hashCode = 1;
        info.err.statusCode = 500;
        return validator.sendError(response, info);
      }

      info.res = {
        'sync': {
          'coins'      : modifed.value.coins,
          'achievments': modifed.value.achievments
        }
      }

      return callResponse(response, info);
    }
  );
}

function pickEverydayAchievement(db, info, response) {
  info.user.coins += info.req.body.coins;
  info.user.achievments.everyday = info.req.body.key + 1;

  if (info.user.achievments.everyday > 4) { info.user.achievments.everyday = 4 }

  db.collection('users').findAndModify(
    {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
    [],
    {$set : {
      'coins'               : info.user.coins,
      'achievments.everyday': info.user.achievments.everyday,
      'lastEveryday'        : dateNow()
    }},
    {new: true},
    function(err, modifed) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        info.err.err = err;
        info.err.from = '/pickEverydayAchievement #1';
        info.err.hashCode = 1;
        info.err.statusCode = 500;
        return validator.sendError(response, info);
      }

      info.res = {
        'sync': {
          'coins'       : modifed.value.coins,
          'achievments' : modifed.value.achievments,
          'lastEveryday': modifed.value.lastEveryday
        }
      }

      return callResponse(response, info);
    }
  );
}

function resetEverydayAch(db, info, response) {
  info.user.lastEveryday = dateNow() - (1 * 60 * 60 * 24 * 1); // today -  1 days

  db.collection('users').findAndModify(
    {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
    [],
    {$set : {
      'achievments.everyday': 0,
      'lastEveryday'        : info.user.lastEveryday
    }},
    {new: true},
    function(err, modifed) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        info.err.err = err;
        info.err.from = '/resetEverydayAch #1';
        info.err.hashCode = 1;
        info.err.statusCode = 500;
        return validator.sendError(response, info);
      }

      info.res = {
        'sync': {
          'achievments' : modifed.value.achievments,
          'lastEveryday': modifed.value.lastEveryday
        }
      }

      return callResponse(response, info);
    }
  );
}

function buyThing(db, info, response) {
  return purchase(db, info, response, '/buyThing #1', function(info) {
    return changeClothes(db, info, response, '/buyThing #2', function(info) {

      var thingsEvil = info.user.thingsEvil;
      var thingsGood = info.user.thingsGood;

      if (info.req.body.force == 'forceEvil') {
        thingsEvil[info.req.body.position] = true;
      }

      if (info.req.body.force == 'forceGood') {
        thingsGood[info.req.body.position] = true;
      }

      db.collection('users').findAndModify(
        {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
        [],
        {$set: {
          'thingsEvil': thingsEvil,
          'thingsGood': thingsGood
        }},
        {new: true},
        function(err, modifed) {
          if (!_.isUndefined(err) && !_.isNull(err)) {
            info.err.err = err;
            info.err.from = '/buyThing #3';
            info.err.hashCode = 1;
            info.err.statusCode = 500;
            return validator.sendError(response, info);
          }

          info.res = {
            'sync': {
              'coins'         : modifed.value.coins,
              'thingsEvil'    : modifed.value.thingsEvil,
              'thingsGood'    : modifed.value.thingsGood,
              'thingsAtPlayer': modifed.value.thingsAtPlayer
            }
          }

          return callResponse(response, info);
        }
      );
    });
  });
}

function changeClothes(db, info, response, from, cb) {
  if (_.isUndefined(from) || _.isNull(from)) {
    from = 'null';
  }

  var off = false;
  var tap = info.user.thingsAtPlayer;

  for (var key in tap) {
    if (tap[key].force === info.req.body.force && tap[key].num === info.req.body.num && tap[key].name === info.req.body.name) {
      off = true;
    }

    if (tap[key].name === info.req.body.name) {
      tap.splice(key, 1);
    }
  }

  if (!off) {
    tap.push({'force': info.req.body.force, 'num': info.req.body.num, 'name': info.req.body.name});
  } else if (info.req.body.name === 'face') {
    tap.push({'force': 'common', 'num': 0, 'name': 'face'});
  }

  db.collection('users').findAndModify(
    {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
    [],
    {$set: {'thingsAtPlayer': tap}},
    {new: true},
    function(err, modifed) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        info.err.err = err;
        info.err.from = from + ' -> /changeClothes #1';
        info.err.hashCode = 1;
        info.err.statusCode = 500;
        return validator.sendError(response, info);
      }

      if (!_.isUndefined(cb) && !_.isNull(cb) && _.isFunction(cb)) {
        info.user = modifed.value;
        return cb(info);
      } else {
        info.res = {
          'sync': {
            'thingsAtPlayer': modifed.value.thingsAtPlayer
          }
        }

        return callResponse(response, info);
      }
    }
  );
}

function buyBot(db, info, response) {
  return purchase(db, info, response, '/buyBot #1', function(info) {
    if(info.req.body.force === 'common') {var name = 'botCommon';}
    if(info.req.body.force === 'evil')   {var name = 'botEvil';  }
    if(info.req.body.force === 'good')   {var name = 'botGood';  }

    if(_.isUndefined(info.user[name][post.level]) || _.isNull(info.user[name][post.level])) {
      info.user[name][post.level] = 0;
    }

    info.user[name][post.level] += 1;

    db.collection('users').findAndModify(
      {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
      [],
      {$set: {
        'botCommon': info.user.botCommon,
        'botEvil'  : info.user.botEvil,
        'botGood'  : info.user.botGood
      }},
      {new: true},
      function(err, modifed) {
        if (!_.isUndefined(err) && !_.isNull(err)) {
          info.err.err = err;
          info.err.from = '/buyBot #2';
          info.err.hashCode = 1;
          info.err.statusCode = 500;
          return validator.sendError(response, info);
        }

        info.res = {
          'sync': {
            'coins'     : modifed.value.coins,
            'botCommon' : modifed.value.botCommon,
            'botEvil'   : modifed.value.botEvil,
            'botGood'   : modifed.value.botGood
          }
        }

        return callResponse(response, info);
      }
    );
  });
}

function buyBooster(db, info, response) {
  return purchase(db, info, response, '/buyBooster #1', function(info) {
    if (info.req.body.name === 'playerDoubleStr') { info.user.playerDoubleStr += info.req.body.count}
    if (info.req.body.name === 'botDoubleStr')    { info.user.botDoubleStr    += info.req.body.count}
    if (info.req.body.name === 'botDoubleSpeed')  { info.user.botDoubleSpeed  += info.req.body.count}

    db.collection('users').findAndModify(
      {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
      [],
      {$set : {
        'playerDoubleStr': info.user.playerDoubleStr,
        'botDoubleStr'   : info.user.botDoubleStr,
        'botDoubleSpeed' : info.user.botDoubleSpeed
      }},
      {new: true},
      function(err, modifed) {
        if (!_.isUndefined(err) && !_.isNull(err)) {
          info.err.err = err;
          info.err.from = '/buyBooster #2';
          info.err.hashCode = 1;
          info.err.statusCode = 500;
          return validator.sendError(response, info);
        }

        info.res = {
          'sync': {
            'coins'          : modifed.value.coins,
            'playerDoubleStr': modifed.value.playerDoubleStr,
            'botDoubleStr'   : modifed.value.botDoubleStr,
            'botDoubleSpeed' : modifed.value.botDoubleSpeed
          }
        }

        return callResponse(response, info);
      }
    );
  });
}

function purchase(db, info, response, from, cb) {
  if (_.isUndefined(from) || _.isNull(from)) {
    from = 'null';
  }

  if (info.user.coins - info.req.body.cost < 0) {
    info.notification = {
      'from': from + ' -> /purchase #1',
      'hashCode': 0
    }

    return validator.sendNotification(response, info);

  } else {
    db.collection('users').findAndModify(
      {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
      [],
      {$inc : { 'coins': -info.req.body.cost } },
      {new: true},
      function(err, modifed) {
        if (!_.isUndefined(err) && !_.isNull(err)) {
          info.err.err = err;
          info.err.from = from + ' -> /purchase #2';
          info.err.hashCode = 1;
          info.err.statusCode = 500;
          return validator.sendError(response, info);
        }

        if (!_.isUndefined(cb) && !_.isNull(cb) && _.isFunction(cb)) {
          info.user = modifed.value;
          return cb(info);
        } else {
          info.res = {
            'sync': {
              'coins': modifed.value.coins
            }
          }
          return callResponse(response, info);
        }
      }
    );
  }
}

function getWorldStatistic(db, info, response) {
  function a(err, result) {
    if (!_.isNull(err)) {
      info.err.err = err;
      info.err.from = '/getWorldStatistic #1';
      info.err.hashCode = 1;
      info.err.statusCode = 500;
      return validator.sendError(response, info);
    }

    var myPosition = result.length - 1;

    function b(err, result) {
      if (!_.isNull(err)) {
        info.err.err = err;
        info.err.from = '/getWorldStatistic #2';
        info.err.hashCode = 1;
        info.err.statusCode = 500;
        return validator.sendError(response, info);
      }

      if (_.include([0, 1, 2, 3, 4], myPosition)) {
        search = [0, 1, 2, 3, 4, 5];
      } else {
        if (_.has(result, myPosition + 1)) {
          search = [0, 1, 2, myPosition - 1, myPosition, myPosition + 1];
        } else {
          search = [0, 1, 2, myPosition - 2, myPosition - 1, myPosition];
        }
      }

      info.res = {
        'people': []
      }

      for(var i = 0; i < search.length; i++) {
        num = search[i];
        if (_.has(result, num)) {
          obj = null

          obj = {
            id        : result[num].id,
            firstName : result[num].firstName,
            lastName  : result[num].lastName,
            photo100  : result[num].photo100,
            exp       : result[num].exp,
            level     : result[num].level,
            forceEvil : result[num].forceEvil,
            forceGood : result[num].forceGood,
            position  : num + 1
          }

          if (num === myPosition) { obj.isPlayer = true }

          info.res.people.push(obj);
        }
      }

      return callResponse(response, info);
    }

    if (info.req.body.socialNetwork == 'test') {
      db.collection('users').find().sort({totalExp : -1}).toArray(function(err, found) {
        b(err, found);
      });
    } else {
      db.collection('users').find({ socialNetwork: {$nin: ['test', null]}}).sort({totalExp : -1}).toArray(function(err, found) {
        b(err, found);
      });
    }
  }

  if (info.req.body.socialNetwork == 'test') {
    db.collection('users').find({totalExp: { $gte: info.user.totalExp }}).sort({totalExp : -1}).toArray(function(err, found) {
      a(err, found);
    });
  } else {
    db.collection('users').find({ socialNetwork:{$nin: ['test', null]}, totalExp:{$gte: info.user.totalExp}}).sort({totalExp : -1}).toArray(function(err, found) {
      a(err, found);
    });
  }
}

function getCoins(db, info, response) {
  db.collection('users').findAndModify(
    {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
    [],
    {$inc : { 'coins': info.req.body.coins}},
    {new: true},
    function(err, modifed) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        info.err.err = err;
        info.err.from = '/getCoins #1';
        info.err.hashCode = 1;
        info.err.statusCode = 500;
        return validator.sendError(response, info);
      }

      info.res = {
        'sync': {
          'coins': modifed.value.coins
        }
      }

      return callResponse(response, info);
    }
  );
}

function getAllThings(db, info, response) {
  getInformation(db, function (err, result) {
    if (!_.isUndefined(err) && !_.isNull(err)) {
      if (!_.isObject(err)) { var err = {}; }
      if (!_.has(err, 'err')) { err.err = null; }
      if (!_.has(err, 'from')) { err.from = '/getAllThings #1'; }
      else { err.from = '/getAllThings #2 -> ' + from; }
      info.err.err = err.err;
      info.err.from = err.from;
      info.err.hashCode = 1;
      info.err.statusCode = 500;
      return validator.sendError(response, info);
    }

    var countEvilThins = _.chain(result.shop.thing)
      .filter(function(thing) { return thing.force === 'forceEvil' })
      .size()
      .value();

    var countGoodThins = _.chain(result.shop.thing)
      .filter(function(thing) { return thing.force === 'forceGood' })
      .size()
      .value();

    _.each(_.range(countEvilThins), function(num) {info.user.thingsEvil[num] = true});
    _.each(_.range(countGoodThins), function(num) {info.user.thingsGood[num] = true});

    db.collection('users').findAndModify(
      {'id': info.req.body.id, 'socialNetwork': info.req.body.socialNetwork},
      [],
      {$set : {
        'thingsEvil': info.user.thingsEvil,
        'thingsGood': info.user.thingsGood
      }},
      {new: true},
      function(err, modifed) {
        if (!_.isUndefined(err) && !_.isNull(err)) {
          info.err.err = err;
          info.err.from = '/getAllThings #1';
          info.err.hashCode = 1;
          info.err.statusCode = 500;
          return validator.sendError(response, info);
        }

        info.res = {
          'sync': {
            'thingsEvil': modifed.value.thingsEvil,
            'thingsGood': modifed.value.thingsGood
          }
        }

        return callResponse(response, info);
      }
    );
  });
}

function callResponse(response, info) {
  if (_.isUndefined(info.res) || _.isNull(info.res) || !_.isObject(info.res)) { info.res = {}; }
  if (!_.has(info.res, 'sync')) { info.res.sync = {}; }

  info.res.sync.dateNow = dateNow();

  info.res.sync.globalEvilAll     = globalEvilAll;
  info.res.sync.globalGoodAll     = globalGoodAll;
  info.res.sync.globalEvilNetwork = globalEvilNetwork;
  info.res.sync.globalGoodNetwork = globalGoodNetwork;

  response.writeHead(200, {'Content-Type': 'application/json', 'charset':'UTF-8', 'Access-Control-Allow-Origin':'*'});
  response.write(JSON.stringify({'res': info.res}));
  console.timeEnd(info.req.pathname);
  return response.end();
}

exports.authorization           = authorization;
exports.resetUser               = resetUser;
exports.save                    = save;
exports.pickAchievement         = pickAchievement;
exports.pickEverydayAchievement = pickEverydayAchievement;
exports.resetEverydayAch        = resetEverydayAch;
exports.buyThing                = buyThing;
exports.changeClothes           = changeClothes;
exports.buyBot                  = buyBot;
exports.buyBooster              = buyBooster;
exports.getWorldStatistic       = getWorldStatistic;
exports.getCoins                = getCoins;
exports.getAllThings            = getAllThings;
