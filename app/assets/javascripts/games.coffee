gameReady = ->
  $('.in-game-remove').on 'ajax:success', ->
    Turbolinks.visit("/rooms/#{$('#room_name').val()}")
 
  game_id = $('#game_id').val()
  $canvas = $('#gomoku-board')

  if $canvas.length
    @game = new Game(game_id, $canvas.get(0))

getMousePos = (canvas, evt) ->
  rect = canvas.getBoundingClientRect()
  scaleX = canvas.width / rect.width
  scaleY = canvas.height / rect.height
  # relationship bitmap vs. element for Y
  {
    x: (evt.clientX - (rect.left)) * scaleX
    y: (evt.clientY - (rect.top)) * scaleY
  }

getCoords = (canvas, evt) ->
  xy = getMousePos(canvas, evt)
  {
    x: parseInt(xy.x / canvas.width * 15)
    y: parseInt(xy.y / canvas.height * 15)
  }

class Game
  self = this
  constructor: (@id, @canvas) ->
    @context = @canvas.getContext('2d')
    @drawBoard()
    @pullBoard()
    $(@canvas).on 'click', (e) -> 
      coords = getCoords(this, e)
      self.pushMove(coords)
      # window.game.drawStone('white', coords)

  pushMove: (coords) ->
    $.ajax
      method: 'POST'
      url: "/games/#{@id}/push_move"
      data:
        x: coords.x
        y: coords.y
      error: (data) ->
        alert(data.statusText) unless data.status == 422
      # no success callback (this belongs to websockets)

  pullBoard: ->
    self = this
    $.ajax
      method: 'GET'
      url: "/games/#{@id}/board"
      success: (data) ->
        for [x, y] in data.white
          self.drawStone 'white', x: x, y: y
        for [x, y] in data.black
          self.drawStone 'black', x: x, y: y
      error: (data) ->
        alert("Could not load board: #{data.statusText}")

  drawBoard: ->
    bw = 718
    bh = 718
    @canvas.width = bw
    @canvas.height = bh
    @p = 23.9333
    cw = bw + (@p*2) + 1
    ch = bh + (@p*2) + 1

    for x in [0..bw - @p*2] by @p*2
      @context.moveTo(0.5 + x + @p, @p)
      @context.lineTo(0.5 + x + @p, bh - @p)

    for x in [0..bh - @p*2] by @p*2
      @context.moveTo(@p, 0.5 + x + @p)
      @context.lineTo(bw - @p, 0.5 + x + @p)

    @context.strokeStyle = "black"
    @context.lineWidth = 3
    @context.closePath()
    @context.stroke()

  pos: (coords) ->
    {
      x: @p + (coords.x * @p * 2)
      y: @p + (coords.y * @p * 2)
    }

  drawStone: (color, coords) ->
    stonePos = @pos(coords)

    innerRadius = 5
    outerRadius = 20
    radius = 18

    gradient = @context.createRadialGradient stonePos.x, stonePos.y, innerRadius, stonePos.x, stonePos.y, outerRadius
    
    if color == 'white'
      gradient.addColorStop 0, 'white'
      gradient.addColorStop 1, 'gray'
    else
      gradient.addColorStop 0, '#444444'
      gradient.addColorStop 1, 'black'

    @context.fillStyle = gradient
    @context.beginPath()
    @context.arc stonePos.x, stonePos.y, radius, 0, 2 * Math.PI
    @context.fill()
    @context.closePath()


$(document).on 'turbolinks:load', ->
  gameReady()

