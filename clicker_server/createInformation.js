var MongoClient = require('mongodb').MongoClient;
var url = 'mongodb://localhost:27017/clickerTest';

MongoClient.connect(url, function(err, db) {
  info = db.collection('information');

  info.drop({}, function (err, remove) {
    if (err) {
      console.log('Error #A:', err);
      console.log('Error #B:', remove);
      db.close();
    }

    info.insert({
      'achievments' : {
        'everyday': {
          '0': {
            'task': 1,
            'product': {
              'coins' : 100
            }
          },
          '1': {
            'task': 2,
            'product': {
              'coins' : 200
            }
          },
          '2': {
            'task': 3,
            'product': {
              'coins' : 400
            }
          },
          '3': {
            'task': 4,
            'product': {
              'coins' : 700
            }
          },
          '4': {
            'task': 5,
            'product': {
              'coins' : 1000
            }
          }
        },
        'friendsPlay': {
          '0': {
            'task': 5,
            'product': {
              'coins' : 1000
            }
          },
          '1': {
            'task': 10,
            'product': {
              'coins' : 2000
            }
          },
          '2': {
            'task': 15,
            'product': {
              'coins' : 3000
            }
          },
          '3': {
            'task': 20,
            'product': {
              'coins' : 5000
            }
          },
          '4': {
            'task': 30,
            'product': {
              'coins' : 10000
            }
          }
        },
        'level': {
          '0': {
            'task': 5,
            'product': {
              'coins' : 100
            }
          },
          '1': {
            'task': 10,
            'product': {
              'coins' : 300
            }
          },
          '2': {
            'task': 30,
            'product': {
              'coins' : 3000
            }
          },
          '3': {
            'task': 100,
            'product': {
              'coins' : 5000
            }
          },
          '4': {
            'task': 250,
            'product': {
              'coins' : 10000
            }
          }
        },
        'coins': {
          '0': {
            'task': 500,
            'product': {
              'coins' : 500
            }
          },
          '1': {
            'task': 4000,
            'product': {
              'coins' : 1000
            }
          },
          '2': {
            'task': 10000,
            'product': {
              'coins' : 3000
            }
          },
          '3': {
            'task': 15000,
            'product': {
              'coins' : 5000
            }
          },
          '4': {
            'task': 20000,
            'product': {
              'coins' : 10000
            }
          }
        },
        'countClick': {
          '0': {
            'task': 5,
            'product': {
              'coins' : 50
            }
          },
          '1': {
            'task': 500,
            'product': {
              'coins' : 150
            }
          },
          '2': {
            'task': 5000,
            'product': {
              'coins' : 2000
            }
          },
          '3': {
            'task': 50000,
            'product': {
              'coins' : 5000
            }
          },
          '4': {
            'task': 300000,
            'product': {
              'coins' : 10000
            }
          }
        },
        'forceEvil': {
          '0': {
            'task': 5000,
            'product': {
              'coins' : 200
            }
          },
          '1': {
            'task': 10000,
            'product': {
              'coins' : 500
            }
          },
          '2': {
            'task': 30000,
            'product': {
              'coins' : 1500
            }
          },
          '3': {
            'task': 100000,
            'product': {
              'coins' : 5000
            }
          },
          '4': {
            'task': 1000000,
            'product': {
              'coins' : 10000
            }
          }
        },
        'forceGood': {
          '0': {
            'task': 5000,
            'product': {
              'coins' : 200
            }
          },
          '1': {
            'task': 10000,
            'product': {
              'coins' : 500
            }
          },
          '2': {
            'task': 30000,
            'product': {
              'coins' : 1500
            }
          },
          '3': {
            'task': 100000,
            'product': {
              'coins' : 5000
            }
          },
          '4': {
            'task': 1000000,
            'product': {
              'coins' : 10000
            }
          }
        },
        'timeForEvil': {
          '0': {
            'task': 2000,
            'product': {
              'coins' : 200
            }
          },
          '1': {
            'task': 5000,
            'product': {
              'coins' : 1000
            }
          },
          '2': {
            'task': 50000,
            'product': {
              'coins' : 3000
            }
          },
          '3': {
            'task': 500000,
            'product': {
              'coins' : 5000
            }
          },
          '4': {
            'task': 5000000,
            'product': {
              'coins' : 10000
            }
          }
        },
        'timeForGood': {
          '0': {
            'task': 2000,
            'product': {
              'coins' : 200
            }
          },
          '1': {
            'task': 5000,
            'product': {
              'coins' : 1000
            }
          },
          '2': {
            'task': 50000,
            'product': {
              'coins' : 3000
            }
          },
          '3': {
            'task': 500000,
            'product': {
              'coins' : 5000
            }
          },
          '4': {
            'task': 5000000,
            'product': {
              'coins' : 10000
            }
          }
        },
        'countOfBots': {
          '0': {
            'task': 10,
            'product': {
              'coins' : 100
            }
          },
          '1': {
            'task': 50,
            'product': {
              'coins' : 2000
            }
          },
          '2': {
            'task': 70,
            'product': {
              'coins' : 5000
            }
          },
          '3': {
            'task': 120,
            'product': {
              'coins' : 10000
            }
          },
          '4': {
            'task': 250,
            'product': {
              'coins' : 20000
            }
          }
        },
        'playerDoubleStrWasUsed': {
          '0': {
            'task': 3,
            'product': {
              'coins' : 100
            }
          },
          '1': {
            'task': 5,
            'product': {
              'coins' : 200
            }
          },
          '2': {
            'task': 10,
            'product': {
              'coins' : 250
            }
          },
          '3': {
            'task': 30,
            'product': {
              'coins' : 400
            }
          },
          '4': {
            'task': 50,
            'product': {
              'coins' : 500
            }
          }
        },
        'botDoubleStrWasUsed': {
          '0': {
            'task': 3,
            'product': {
              'coins' : 200
            }
          },
          '1': {
            'task': 5,
            'product': {
              'coins' : 300
            }
          },
          '2': {
            'task': 10,
            'product': {
              'coins' : 350
            }
          },
          '3': {
            'task': 30,
            'product': {
              'coins' : 500
            }
          },
          '4': {
            'task': 50,
            'product': {
              'coins' : 700
            }
          }
        },
        'botDoubleSpeedWasUsed': {
          '0': {
            'task': 3,
            'product': {
              'coins' : 300
            }
          },
          '1': {
            'task': 5,
            'product': {
              'coins' : 400
            }
          },
          '2': {
            'task': 10,
            'product': {
              'coins' : 450
            }
          },
          '3': {
            'task': 30,
            'product': {
              'coins' : 600
            }
          },
          '4': {
            'task': 50,
            'product': {
              'coins' : 900
            }
          }
        }
      },
      'bank': {
        'standart': {
          '0': {
            'product': {
              'vk': 1,
              'coins' : 100
            }
          },
          '1': {
            'product': {
              'vk': 2,
              'coins' : 200
            }
          },
          '2': {
            'product': {
              'vk': 3,
              'coins' : 300
            }
          },
          '3': {
            'product': {
              'vk': 4,
              'coins' : 400
            }
          },
          '4': {
            'product': {
              'vk': 5,
              'coins' : 500
            }
          },
          '5': {
            'product': {
              'vk': 6,
              'coins' : 600
            }
          }
        }
      },
      'shop': {
        'thing': [
          {'position':-1 , 'num': 0, 'name': 'face', 'force': 'common', 'need': {'force': 0, 'cost': 0, 'level': 0}},

          {'position': 0 , 'num': 0, 'name': 'shield', 'force': 'forceEvil', 'need': {'force': 500    , 'cost': 10,   'level': 5}},
          {'position': 0 , 'num': 0, 'name': 'shield', 'force': 'forceGood', 'need': {'force': 500    , 'cost': 10,   'level': 5}},
          {'position': 1 , 'num': 1, 'name': 'shield', 'force': 'forceEvil', 'need': {'force': 1000   , 'cost': 30,   'level': 5}},
          {'position': 1 , 'num': 1, 'name': 'shield', 'force': 'forceGood', 'need': {'force': 1000   , 'cost': 30,   'level': 5}},
          {'position': 2 , 'num': 0, 'name': 'head'  , 'force': 'forceEvil', 'need': {'force': 3000   , 'cost': 60,   'level': 6}},
          {'position': 2 , 'num': 0, 'name': 'head'  , 'force': 'forceGood', 'need': {'force': 3000   , 'cost': 60,   'level': 6}},
          {'position': 3 , 'num': 0, 'name': 'face'  , 'force': 'forceEvil', 'need': {'force': 5000   , 'cost': 100,  'level': 7}},
          {'position': 3 , 'num': 0, 'name': 'face'  , 'force': 'forceGood', 'need': {'force': 5000   , 'cost': 100,  'level': 7}},
          {'position': 4 , 'num': 2, 'name': 'shield', 'force': 'forceEvil', 'need': {'force': 7000   , 'cost': 100,  'level': 8}},
          {'position': 4 , 'num': 2, 'name': 'shield', 'force': 'forceGood', 'need': {'force': 7000   , 'cost': 100,  'level': 8}},
          {'position': 5 , 'num': 1, 'name': 'head'  , 'force': 'forceEvil', 'need': {'force': 10000  , 'cost': 100,  'level': 10}},
          {'position': 5 , 'num': 1, 'name': 'head'  , 'force': 'forceGood', 'need': {'force': 10000  , 'cost': 100,  'level': 10}},
          {'position': 6 , 'num': 1, 'name': 'face'  , 'force': 'forceEvil', 'need': {'force': 15000  , 'cost': 200,  'level': 15}},
          {'position': 6 , 'num': 1, 'name': 'face'  , 'force': 'forceGood', 'need': {'force': 15000  , 'cost': 200,  'level': 15}},
          {'position': 7 , 'num': 0, 'name': 'weapon', 'force': 'forceEvil', 'need': {'force': 20000  , 'cost': 300,  'level': 20}},
          {'position': 7 , 'num': 0, 'name': 'weapon', 'force': 'forceGood', 'need': {'force': 20000  , 'cost': 300,  'level': 20}},
          {'position': 8 , 'num': 3, 'name': 'shield', 'force': 'forceEvil', 'need': {'force': 25000  , 'cost': 400,  'level': 25}},
          {'position': 8 , 'num': 3, 'name': 'shield', 'force': 'forceGood', 'need': {'force': 25000  , 'cost': 400,  'level': 25}},
          {'position': 9 , 'num': 2, 'name': 'head'  , 'force': 'forceEvil', 'need': {'force': 30000  , 'cost': 500,  'level': 30}},
          {'position': 9 , 'num': 2, 'name': 'head'  , 'force': 'forceGood', 'need': {'force': 30000  , 'cost': 500,  'level': 30}},
          {'position': 10, 'num': 2, 'name': 'face'  , 'force': 'forceEvil', 'need': {'force': 40000  , 'cost': 500,  'level': 40}},
          {'position': 10, 'num': 2, 'name': 'face'  , 'force': 'forceGood', 'need': {'force': 40000  , 'cost': 500,  'level': 40}},
          {'position': 11, 'num': 1, 'name': 'weapon', 'force': 'forceEvil', 'need': {'force': 50000  , 'cost': 500,  'level': 50}},
          {'position': 11, 'num': 1, 'name': 'weapon', 'force': 'forceGood', 'need': {'force': 50000  , 'cost': 500,  'level': 50}},
          {'position': 12, 'num': 4, 'name': 'shield', 'force': 'forceEvil', 'need': {'force': 60000  , 'cost': 600,  'level': 60}},
          {'position': 12, 'num': 4, 'name': 'shield', 'force': 'forceGood', 'need': {'force': 60000  , 'cost': 600,  'level': 60}},
          {'position': 13, 'num': 3, 'name': 'head'  , 'force': 'forceEvil', 'need': {'force': 70000  , 'cost': 600,  'level': 70}},
          {'position': 13, 'num': 3, 'name': 'head'  , 'force': 'forceGood', 'need': {'force': 70000  , 'cost': 600,  'level': 70}},
          {'position': 14, 'num': 3, 'name': 'face'  , 'force': 'forceEvil', 'need': {'force': 80000  , 'cost': 600,  'level': 80}},
          {'position': 14, 'num': 3, 'name': 'face'  , 'force': 'forceGood', 'need': {'force': 80000  , 'cost': 600,  'level': 80}},
          {'position': 15, 'num': 0, 'name': 'back'  , 'force': 'forceEvil', 'need': {'force': 90000  , 'cost': 600,  'level': 90}},
          {'position': 15, 'num': 0, 'name': 'back'  , 'force': 'forceGood', 'need': {'force': 90000  , 'cost': 600,  'level': 90}},
          {'position': 16, 'num': 2, 'name': 'weapon', 'force': 'forceEvil', 'need': {'force': 100000 , 'cost': 700,  'level': 100}},
          {'position': 16, 'num': 2, 'name': 'weapon', 'force': 'forceGood', 'need': {'force': 100000 , 'cost': 700,  'level': 100}},
          {'position': 17, 'num': 5, 'name': 'shield', 'force': 'forceEvil', 'need': {'force': 120000 , 'cost': 700,  'level': 110}},
          {'position': 17, 'num': 5, 'name': 'shield', 'force': 'forceGood', 'need': {'force': 120000 , 'cost': 700,  'level': 110}},
          {'position': 18, 'num': 4, 'name': 'head'  , 'force': 'forceEvil', 'need': {'force': 140000 , 'cost': 700,  'level': 120}},
          {'position': 18, 'num': 4, 'name': 'head'  , 'force': 'forceGood', 'need': {'force': 140000 , 'cost': 700,  'level': 120}},
          {'position': 19, 'num': 4, 'name': 'face'  , 'force': 'forceEvil', 'need': {'force': 160000 , 'cost': 700,  'level': 130}},
          {'position': 19, 'num': 4, 'name': 'face'  , 'force': 'forceGood', 'need': {'force': 160000 , 'cost': 700,  'level': 130}},
          {'position': 20, 'num': 1, 'name': 'back'  , 'force': 'forceEvil', 'need': {'force': 180000 , 'cost': 800,  'level': 140}},
          {'position': 20, 'num': 1, 'name': 'back'  , 'force': 'forceGood', 'need': {'force': 180000 , 'cost': 800,  'level': 140}},
          {'position': 21, 'num': 6, 'name': 'shield', 'force': 'forceEvil', 'need': {'force': 200000 , 'cost': 800,  'level': 150}},
          {'position': 21, 'num': 6, 'name': 'shield', 'force': 'forceGood', 'need': {'force': 200000 , 'cost': 800,  'level': 150}},
          {'position': 22, 'num': 3, 'name': 'weapon', 'force': 'forceEvil', 'need': {'force': 250000 , 'cost': 800,  'level': 160}},
          {'position': 22, 'num': 3, 'name': 'weapon', 'force': 'forceGood', 'need': {'force': 250000 , 'cost': 800,  'level': 160}},
          {'position': 23, 'num': 7, 'name': 'shield', 'force': 'forceEvil', 'need': {'force': 300000 , 'cost': 800,  'level': 170}},
          {'position': 23, 'num': 7, 'name': 'shield', 'force': 'forceGood', 'need': {'force': 300000 , 'cost': 800,  'level': 170}},
          {'position': 24, 'num': 5, 'name': 'head'  , 'force': 'forceEvil', 'need': {'force': 350000 , 'cost': 900,  'level': 180}},
          {'position': 24, 'num': 5, 'name': 'head'  , 'force': 'forceGood', 'need': {'force': 350000 , 'cost': 900,  'level': 180}},
          {'position': 25, 'num': 5, 'name': 'face'  , 'force': 'forceEvil', 'need': {'force': 400000 , 'cost': 900,  'level': 190}},
          {'position': 25, 'num': 5, 'name': 'face'  , 'force': 'forceGood', 'need': {'force': 400000 , 'cost': 900,  'level': 190}},
          {'position': 26, 'num': 2, 'name': 'back'  , 'force': 'forceEvil', 'need': {'force': 450000 , 'cost': 900,  'level': 200}},
          {'position': 26, 'num': 2, 'name': 'back'  , 'force': 'forceGood', 'need': {'force': 450000 , 'cost': 900,  'level': 200}},
          {'position': 27, 'num': 4, 'name': 'weapon', 'force': 'forceEvil', 'need': {'force': 500000 , 'cost': 900,  'level': 210}},
          {'position': 27, 'num': 4, 'name': 'weapon', 'force': 'forceGood', 'need': {'force': 500000 , 'cost': 900,  'level': 210}},
          {'position': 28, 'num': 6, 'name': 'head'  , 'force': 'forceEvil', 'need': {'force': 600000 , 'cost': 1000, 'level': 220}},
          {'position': 28, 'num': 6, 'name': 'head'  , 'force': 'forceGood', 'need': {'force': 600000 , 'cost': 1000, 'level': 220}},
          {'position': 29, 'num': 6, 'name': 'face'  , 'force': 'forceEvil', 'need': {'force': 700000 , 'cost': 1000, 'level': 230}},
          {'position': 29, 'num': 6, 'name': 'face'  , 'force': 'forceGood', 'need': {'force': 700000 , 'cost': 1000, 'level': 230}},
          {'position': 30, 'num': 3, 'name': 'back'  , 'force': 'forceEvil', 'need': {'force': 850000 , 'cost': 1000, 'level': 240}},
          {'position': 30, 'num': 3, 'name': 'back'  , 'force': 'forceGood', 'need': {'force': 850000 , 'cost': 1000, 'level': 240}},
          {'position': 31, 'num': 5, 'name': 'weapon', 'force': 'forceEvil', 'need': {'force': 1000000, 'cost': 1000, 'level': 250}},
          {'position': 31, 'num': 5, 'name': 'weapon', 'force': 'forceGood', 'need': {'force': 1000000, 'cost': 1000, 'level': 250}}
        ],
        'bot': {
          '0': {
            'force': 'common',
            'grade': 1,
            'str': {
              'botStr': 0.1,
              'botStrStep': 0.1
            },
             'speed': {
              'botSpeed': 0.1,
              'botSpeedStep': 0.1
            },
            'cost': {
              'costStart': 1,
              'costStep': 1
            },
            'need': {
              'level': 5,
              'forceEvil': 200,
              'forceEvilStep': 200,
              'forceGood': 200,
              'forceGoodStep': 200
            }
          },
          '1': {
            'force': 'evil',
            'grade': 1,
            'str': {
              'botStr': 6,
              'botStrStep': 1
            },
            'cost': {
              'costStart': 12,
              'costStep': 2
            },
            'need': {
              'level': 7,
              'forceEvil': 5000,
              'forceEvilStep': 500,
              'forceGood':0,
              'forceGoodStep':0
            }
          },
          '2': {
            'force': 'evil',
            'grade': 2,
            'str': {
              'botStr': 35,
              'botStrStep': 5
            },
            'cost': {
              'costStart': 55,
              'costStep': 5
            },
            'need': {
              'level': 20,
              'forceEvil': 20000,
              'forceEvilStep': 1000,
              'forceGood':0,
              'forceGoodStep':0
            }
          },
          '3': {
            'force': 'evil',
            'grade': 3,
            'str': {
              'botStr': 160,
              'botStrStep': 10
            },
            'cost': {
              'costStart': 110,
              'costStep': 10
            },
            'need': {
              'level': 70,
              'forceEvil': 70000,
              'forceEvilStep': 3000,
              'forceGood':0,
              'forceGoodStep':0
            }
          },
          '4': {
            'force': 'evil',
            'grade': 4,
            'str': {
              'botStr': 420,
              'botStrStep': 20
            },
            'cost': {
              'costStart': 320,
              'costStep': 20
            },
            'need': {
              'level': 120,
              'forceEvil': 120000,
              'forceEvilStep': 5000,
              'forceGood':0,
              'forceGoodStep':0
            }
          },
          '5': {
            'force': 'good',
            'grade': 1,
            'speed': {
              'botSpeed': 6,
              'botSpeedStep': 1
            },
            'cost': {
              'costStart': 12,
              'costStep': 2
            },
            'need': {
              'level': 7,
              'forceEvil': 0,
              'forceEvilStep': 0,
              'forceGood': 5000,
              'forceGoodStep': 500
            }
          },
          '6': {
            'force': 'good',
            'grade': 2,
            'speed': {
              'botSpeed': 35,
              'botSpeedStep': 5
            },
            'cost': {
              'costStart': 55,
              'costStep': 5
            },
            'need': {
              'level': 20,
              'forceEvil': 0,
              'forceEvilStep': 0,
              'forceGood': 20000,
              'forceGoodStep': 1000
            }
          },
          '7': {
            'force': 'good',
            'grade': 3,
            'speed': {
              'botSpeed': 160,
              'botSpeedStep': 10
            },
            'cost': {
              'costStart': 110,
              'costStep': 10
            },
            'need': {
              'level': 70,
              'forceEvil': 0,
              'forceEvilStep': 0,
              'forceGood': 70000,
              'forceGoodStep': 3000
            }
          },
          '8': {
            'force': 'good',
            'grade': 4,
            'speed': {
              'botSpeed': 420,
              'botSpeedStep': 20
            },
            'cost': {
              'costStart': 320,
              'costStep': 20
            },
            'need': {
              'level': 120,
              'forceEvil': 0,
              'forceEvilStep': 0,
              'forceGood': 120000,
              'forceGoodStep': 5000
            }
          }
        },
        'booster': {
          '0': {
            'name': 'playerDoubleStr',
            'cost': 30,
            'discount': 2,
            'count': 19
          },
          '1': {
            'name': 'botDoubleStr',
            'cost': 40,
            'discount': 2,
            'count': 19
          },
          '2': {
            'name': 'botDoubleSpeed',
            'cost': 50,
            'discount': 2,
            'count': 19
          }
        }
      }
    }, function(err, record) {
      if (err) {
        console.log('Error #C:', err);
        console.log('Error #D:', record);
        db.close();
      }

      db.close();
      console.log('Default information created.');
    });
  });
});
