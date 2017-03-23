GS = require "../scripts/gameSettings.json"
global.$ = require "jquery"
global.Backbone = require "backbone"
global._ = require "underscore"
global.async = require "async"

global.canvas = new createjs.Stage "canvas"
canvas.enableMouseOver()
createjs.Ticker.setFPS(GS.FPS)
createjs.Ticker.addEventListener "tick", canvas

Preload = require "./preload/preload.coffee"
Preload = new Preload
