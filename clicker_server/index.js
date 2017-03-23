global.fs = require("fs");
global._ = require('underscore');
global.async = require('async');

var server = require('./server');
var globalStatistic = require('./globalStatistic')
var router = require('./router');
var requestHandlers = require('./requestHandlers');
var MongoClient = require('mongodb').MongoClient;
var url = 'mongodb://localhost:27017/clickerTest';
var xml = require('xmlhttprequest').XMLHttpRequest;

var handle = {};
handle['/authorization']           = requestHandlers.authorization;
handle['/resetUser']               = requestHandlers.resetUser;
handle['/save']                    = requestHandlers.save;
handle['/pickAchievement']         = requestHandlers.pickAchievement;
handle['/pickEverydayAchievement'] = requestHandlers.pickEverydayAchievement;
handle['/resetEverydayAch']        = requestHandlers.resetEverydayAch;
handle['/buyThing']                = requestHandlers.buyThing;
handle['/changeClothes']           = requestHandlers.changeClothes;
handle['/buyBot']                  = requestHandlers.buyBot;
handle['/buyBooster']              = requestHandlers.buyBooster;
handle['/getWorldStatistic']       = requestHandlers.getWorldStatistic;
handle['/getCoins']                = requestHandlers.getCoins;
handle['/getAllThings']            = requestHandlers.getAllThings;

// access_token для vk
// var xhr = new xml();
// var body = 'client_id=5212108&client_secret=W1grGLB9n0ft9Hf1zFk4&grant_type=client_credentials';
// xhr.open('POST', 'https://oauth.vk.com/access_token', false);
// xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
// xhr.onreadystatechange = function() {
//  access_token_temp = JSON.parse(this.responseText)
//   global.access_token_vk = access_token_temp.access_token;
// }
// xhr.send(body);

MongoClient.connect(url, function(err, db) {
  if (!_.isUndefined(err) && !_.isNull(err)) {
    return console.log('Error Start DB:', err);
  }

  globalStatistic.saveGlobal(db);
  return server.start(db, router.route, handle);
});
