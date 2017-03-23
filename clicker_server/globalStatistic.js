var validator = require('./validator.js');

function saveGlobal(db) {
  global.globalEvilAll     = 0;
  global.globalGoodAll     = 0;
  global.globalEvilNetwork = 0;
  global.globalGoodNetwork = 0;

  function save(db) {
    db.collection('globalStatistic').findAndModify(
      {},
      [],
      {$set : {
        'globalEvilAll'    : globalEvilAll,
        'globalGoodAll'    : globalGoodAll,
        'globalEvilNetwork': globalEvilNetwork,
        'globalGoodNetwork': globalGoodNetwork
      }},
      {new: true},
      function(err, modifed) {
        if (!_.isUndefined(err) && !_.isNull(err)) { return sendError('1', err); }

        globalEvilAll     = modifed.value.globalEvilAll;
        globalGoodAll     = modifed.value.globalGoodAll;
        globalEvilNetwork = modifed.value.globalEvilNetwork;
        globalGoodNetwork = modifed.value.globalGoodNetwork;
      }
    );
  }

  db.collection('globalStatistic').findOne({}, function(err, found) {
    if (!_.isUndefined(err) && !_.isNull(err)) { return sendError('2', err); }
    if (_.isEmpty(found)) { return sendError('3', err); }

    globalEvilAll     = found.globalEvilAll;
    globalGoodAll     = found.globalGoodAll;
    globalEvilNetwork = found.globalEvilNetwork;
    globalGoodNetwork = found.globalGoodNetwork;

    setInterval(save, 10000, db);
  });


  function sendError(code, err) {
    console.log('Error! From SaveGlobalForces #' + code);

    fs.appendFile('/var/log/clickerTest.txt', 'Error! From SaveGlobalForces #' + code + '\n\n', function(err) {
      if (!_.isUndefined(err) && !_.isNull(err)) {
        console.log('Need TODO in global statistic! Err: ' + err);
      }
    });
  }
}

exports.saveGlobal = saveGlobal;
