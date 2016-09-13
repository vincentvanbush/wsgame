gameReady = ->
  $('.in-game-remove').on 'ajax:success', ->
    Turbolinks.visit("/rooms/#{$('#room_name').val()}")

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

$(document).on 'turbolinks:load', ->
  gameReady()

  $canvas = $('#gomoku-board')

  if $canvas.length
    canvas = $canvas.get(0)

    bw = 718;
    bh = 718;
    canvas.width = bw
    canvas.height = bh
    p = 23.9333;
    cw = bw + (p*2) + 1
    ch = bh + (p*2) + 1

    context = canvas.getContext("2d")

    drawBoard = ->
      for x in [0..bw - p*2] by 47.8666
        context.moveTo(0.5 + x + p, p)
        context.lineTo(0.5 + x + p, bh - p)


      for x in [0..bh - p*2] by 47.8666
        context.moveTo(p, 0.5 + x + p)
        context.lineTo(bw - p, 0.5 + x + p)

      context.strokeStyle = "black"
      context.lineWidth = 3
      context.stroke()

    drawBoard()

    $canvas.on 'click', (e) ->
      console.log getCoords(canvas, e)

