allVolume = {}
nextMusic = []
sound = {}
s = {}

checkingMusic = false
checkingSound = false

sound.play = (name, type) =>
  s[name] =
    sound: createjs.Sound.play name
    type : type

  s[name].sound.setVolume(allVolume[type])

sound.playSound = (name) =>
  return if checkingSound

  checkingSound = true
  sound.checkFile name, (err) =>
    checkingSound = false

    return if err?

    sound.play name, 'sound'

sound.replayMusic = => sound.playMusic()

sound.playMusic = (name = nextMusic) =>
  return if checkingMusic

  checkingMusic = true
  sound.checkFile name, (err) =>
    checkingMusic = false

    return if err?

    nextMusic = name

    return if _.chain(s)
      .filter (obj) => obj.type == 'music'
      .some (obj) => obj.sound.position
      .value()

    sound.play name, 'music'

    s[name].sound.on 'complete', sound.replayMusic, null, true

sound.checkFile = (name, cb) =>
  fileLoadResources = (val) => console.log "A file has loaded of type: #{val.item.type}, id: #{val.item.id}"

  completeFile = =>
    preload.removeAllEventListeners()
    s[name] ?= {}
    cb?()

  errorFile = =>
    preload.removeAllEventListeners()
    cb?(true)

  if not s[name]?
    preload.loadFile({id: name, src: './sounds/' + name + '.ogg'})
    preload.on('complete', completeFile)
    preload.on('error'   , errorFile)
    preload.on("fileload", fileLoadResources)
  else
    cb?()

sound.resetVolume = =>
  _.each allVolume, (volume, type) =>
    _.each s, (val) =>
      if val.type == type then val.sound.setVolume(volume)

sound.setVolume = (type, volume) =>
  volume /= 100

  allVolume[type] = volume

  for key, val of s
    if s[key].type == type
      s[key].sound.setVolume(volume)

# sound.checkNextMusic = =>
#   return if _.chain(s)
#     .filter (obj) => obj.type == 'music'
#     .some (obj) => obj.sound.position
#     .value()

# sound.stop = (name) =>
#   s[name].sound.stop()
#   s[name].sound.off()

# sound.resume = (name) =>
#   sound.stop name
#   sound.play name

module.exports = sound
