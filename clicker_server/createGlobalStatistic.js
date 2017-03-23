var MongoClient = require('mongodb').MongoClient;
var url = 'mongodb://localhost:27017/clickerTest';

MongoClient.connect(url, function(err, db) {
  globalStatistic = db.collection("globalStatistic");

  globalStatistic.remove({}, function (err, remove) {
    if (err) {
      console.log("Error #A:", err);
      console.log("Error #B:", remove);
      db.close();
    }

    globalStatistic.insert({
      'globalEvilAll'    : 0,
      'globalGoodAll'    : 0,
      'globalEvilNetwork': 0,
      'globalGoodNetwork': 0
    }, function(err, record) {
      if (err) {
        console.log("Error #C:", err);
        console.log("Error #D:", record);
        db.close();
      }

      db.close();
      console.log("Default globalStatistic created.");
    });
  });
});

