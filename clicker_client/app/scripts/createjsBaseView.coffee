GS = require "./gameSettings.json"

class CreatejsBase extends Backbone.View
  cjAddContainer: (x, y, name, parent = canvas, parameters = {} ) ->
    container = new createjs.Container()

    container.set
      x: x
      y: y

    for key, value of parameters
      container.set "#{key}": value

    parent.addChild(container)

  cjAddDraw: (x, y, width, height, name, parent = canvas, options = {}, parameters = {}, hangeable = false) ->
    draw = new createjs.Shape()

    for key, val of options
      if key == "Fill"        then draw.graphics.beginFill(val)
      if key == "RoundRect"   then draw.graphics.drawRoundRectComplex(0, 0, width, height, val[0], val[1], val[2], val[3])
      if key == "Circle"      then draw.graphics.drawCircle(0, 0, width)    #  width == radius
      if key == "Arc"         then draw.graphics.arc(val.x, val.y, width, val.startAngle, val.endAngle, val.antiClockWise)   #  width == radius
      if key == "Rect"        then draw.graphics.drawRect(0, 0, width, height)
      if key == "StrokeStyle" then draw.graphics.setStrokeStyle(val)
      if key == "Stroke"      then draw.graphics.beginStroke(val)
      if key == "Line"
        for move in val
          draw.graphics.lineTo(move[0], move[1])

    if hangeable
      dr = draw.graphics.command

    if not options.Circle?.center and options.Circle?
      x += width
      y += width

    draw.set
      x: x
      y: y

    for key, value of parameters
      draw.set "#{key}": value

    parent.addChild draw
    if hangeable then {shape: draw, draw: dr} else draw

  cjAddBitmap: (x, y, img, parent = canvas, parameters = {}) ->
    return if not img?

    bitmap = new createjs.Bitmap(img);

    bitmap.set
      x     : x ? bitmap.x
      y     : y ? bitmap.y
      scaleX: parameters.scaleX ? bitmap.scaleX
      scaleY: parameters.scaleY ? bitmap.scaleY

    parent.addChild bitmap

  cjAddImage: (x, y, name, parent = canvas, parameters = {}, center = true, scale = false, greateMax = true) ->
    # center - центровка по ширине/высоте родителя, текущего спрайта
    # scale - масштабирование, если указана только ширина или высота, масштабирование будет пропорционально, если указаны оба параметра - то будут применены оба без соблюдения пропорций
    # greateMax - если новый размер, после скалирования, становиться больше, чем размер спрайта изначально, то - применять или нет
    if not preload.getResult(sprites[name]?.image)?
      console.error "Not Found Image"
      return

    data = {
      images: [preload.getResult(sprites[name].image)]
      frames: [
        [sprites[name].x - 2, sprites[name].y - 2, sprites[name].width + 4, sprites[name].height + 4]
      ]
    }

    spriteSheet = new createjs.SpriteSheet(data)
    animation = new createjs.Sprite(spriteSheet)

    if scale
      if parameters.width? and parameters.height?
        newWidth  = parameters.width
        newHeight = parameters.height
        if not greateMax and newWidth  > sprites[name].width  then newWidth  = sprites[name].width
        if not greateMax and newHeight > sprites[name].height then newHeight = sprites[name].height

      else if parameters.width? and not parameters.height?
        newWidth = parameters.width
        if not greateMax and newWidth > sprites[name].width then newWidth = sprites[name].width
        newHeight = sprites[name].height / (sprites[name].width / newWidth)
        if not greateMax and newHeight > sprites[name].height then newHeight = sprites[name].height

      else if parameters.height? and not parameters.width?
        newHeight = parameters.height
        if not greateMax and newHeight > sprites[name].height then newHeight = sprites[name].height
        newWidth = sprites[name].width / (sprites[name].height / newHeight)
        if not greateMax and newWidth > sprites[name].width then newWidth = sprites[name].width

      else if parent.width? and parent.height?
        newWidth  = parent.width
        newHeight = parent.height
        if not greateMax and newWidth  > sprites[name].width  then newWidth  = sprites[name].width
        if not greateMax and newHeight > sprites[name].height then newHeight = sprites[name].height

      else if parent.width? and not parent.height?
        newWidth = parent.width
        if not greateMax and newWidth > sprites[name].width then newWidth = sprites[name].width
        newHeight = sprites[name].height / (sprites[name].width / newWidth)
        if not greateMax and newHeight > sprites[name].height then newHeight = sprites[name].height

      else if parent.height? and not parent.width?
        newHeight = parent.height
        if not greateMax and newHeight > sprites[name].height then newHeight = sprites[name].height
        newWidth = sprites[name].width / (sprites[name].height / newHeight)
        if not greateMax and newWidth > sprites[name].width then newWidth = sprites[name].width

      else
        newWidth  = 0
        newHeight = 0

      newScaleX = newWidth  / sprites[name].width
      newScaleY = newHeight / sprites[name].height

      animation.scaleX = newScaleX
      animation.scaleY = newScaleY

    if center
      w = newWidth  ? parameters.width  ? sprites[name].width  ? parent.width
      h = newHeight ? parameters.height ? sprites[name].height ? parent.height
      x += parent.width  / 2 - w / 2
      y += parent.height / 2 - h / 2

    animation.set
      x: x - 2 # -2 для игнорирования padding в спрайтах
      y: y - 2 # -2 для игнорирования padding в спрайтах

    for key, value of parameters
      animation.set "#{key}": value

    parent.addChild animation

  cjChangeImage: (oldImg, name) ->
    return if not preload.getResult(sprites[name]?.image)?

    oldImg.spriteSheet._frames[0].rect.width = sprites[name].width
    oldImg.spriteSheet._frames[0].rect.height = sprites[name].height
    oldImg.spriteSheet._frames[0].rect.x = sprites[name].x
    oldImg.spriteSheet._frames[0].rect.y = sprites[name].y

  cjAddText: (x, y, text, font, color, name, parent = canvas, parameters = {}) ->
    parameters.width ?= parent.width ? 0

    if parameters.width?
      textContainer = new createjs.Container()
      textContainer.x = x
      textContainer.setBounds(0, 0, parameters.width, 0)
      textContainer.name = "textContainerFor#{name}"

    draw = new createjs.Text(text, font, color)

    if @getNameBrowser() == 'Firefox' then y += 4 # костыль для огненного лиса, шрифт без него ползет вверх

    draw.set
      x: x
      y: y
      lineWidth: parent.width
      textAlign: "center"

    for key, value of parameters
      draw.set "#{key}": value

    if textContainer?
      textContainer.addChild draw

      b = textContainer.getBounds()
      draw.x = parameters.width - b.width / 2

    if textContainer?
      parent.addChild textContainer
    else
      parent.addChild draw

  cjAddHoverActiveBlock: (btn1, btn2, btn3, parent = canvas, margin = true) ->
    btn = @cjAddDraw btn1.x, btn1.y, btn1.w, btn1.h, btn1.n, btn1.p, btn1.o, btn1.parameters, btn1.hangeable

    parent.cursor = "pointer"
    parent.mouseChildren = false

    parent.addEventListener "mouseover", (val) =>
      parent.overBool = true
      if not parent.pushBool
        @cjChangeDraw btn1.x, btn1.y, btn2.w, btn2.h, btn2.o, btn2.parameters, btn if btn2?
      else
        if margin then parent.set y: parent.y + 1
        if btn3?
          @cjChangeDraw btn1.x, btn1.y, btn3.w, btn3.h, btn3.o, btn3.parameters, btn
        else if btn2?
          @cjChangeDraw btn1.x, btn1.y, btn2.w, btn2.h, btn2.o, btn2.parameters, btn

    parent.addEventListener "mouseout", (val) =>
      parent.overBool = false
      if parent.pushBool and margin then parent.set y: parent.y - 1
      @cjChangeDraw btn1.x, btn1.y, btn1.w, btn1.h, btn1.o, btn1.parameters, btn if btn1?

    parent.addEventListener "mousedown", =>
      parent.pushBool = true
      if margin then parent.set y: parent.y + 1
      @cjChangeDraw btn1.x, btn1.y, btn3.w, btn3.h, btn3.o, btn3.parameters, btn if btn3?

    parent.addEventListener "pressup", =>
      parent.pushBool = false
      if parent.overBool and margin then parent.set y: parent.y - 1
      if not parent.overBool
        @cjChangeDraw btn1.x, btn1.y, btn1.w, btn1.h, btn1.o, btn1.parameters, btn if btn1?
      else if parent.overBool
        @cjChangeDraw btn1.x, btn1.y, btn2.w, btn2.h, btn2.o, btn2.parameters, btn if btn2?

    btn

  cjAddClickActive: (btn) ->
    btn.cursor = "pointer"
    btn.mouseChildren = false

    btn.addEventListener "mouseover", (val) =>
      btn.overBool = true
      if btn.pushBool then btn.set y: btn.y + 1

    btn.addEventListener "mouseout", (val) =>
      btn.overBool = false
      if btn.pushBool then btn.set y: btn.y - 1

    btn.addEventListener "mousedown", =>
      btn.pushBool = true
      btn.set y: btn.y + 1

    btn.addEventListener "pressup", =>
      btn.pushBool = false
      if btn.overBool then btn.set y: btn.y - 1

    btn

  cjChangeDraw: (x, y, width, height, options = {}, parameters = {}, draw) ->
    draw.graphics.clear()

    for key, val of options
      if key == "Fill"        then draw.graphics.beginFill(val)
      if key == "RoundRect"   then draw.graphics.drawRoundRectComplex(0, 0, width, height, val[0], val[1], val[2], val[3])
      if key == "Circle"      then draw.graphics.drawCircle(0, 0, width)   #  width == radius
      if key == "Arc"         then draw.graphics.arc(val.x, val.y, width, val.startAngle, val.endAngle)   #  width == radius
      if key == "Rect"        then draw.graphics.drawRect(0, 0, width, height)
      if key == "StrokeStyle" then draw.graphics.setStrokeStyle(val)
      if key == "Stroke"      then draw.graphics.beginStroke(val)
      if key == "Line"
        for move in val
          draw.graphics.lineTo(move[0], move[1])

    if not options.Circle?.center and options.Circle?
      x += width
      y += width

    draw.set
      x: x
      y: y

    for key, value of parameters
      draw.set "#{key}": value

    draw.graphics.endFill()

    draw

  cjRemoveAllEventListeners: (name) ->
    name.removeAllEventListeners()
    name.cursor = "arrow"
    # $("#canvas").css('cursor', 'default')

  cjRemove: (name, parent = canvas) ->
    @cjRemoveAllEventListeners name
    if name.contains then name.removeAllChildren()
    parent.removeChild name


  getNameBrowser: ->
    ua = navigator.userAgent

    return if ua.search(/Firefox/) > -1
      'Firefox'
    else if ua.search(/Chrome/) > -1
      'Chrome'

module.exports = CreatejsBase
