window.blink = (selector, counter = 0) ->
  return if counter >= 10
  new_opacity = if $(selector).css('opacity') == '1'
                  '0'
                else
                  '1'
  $('.blink-after-move').animate
    opacity: new_opacity
    100
    -> setTimeout(->
         blink(selector, counter + 1)
       300)

subscribe_game = ->
  game_id = $('#game_id').val()

  if App.game
    App.game.unsubscribe()
    App.cable.subscriptions.remove(App.game)
    App.game = undefined

  if game_id
    App.game = App.cable.subscriptions.create(
      {
        channel: "GameChannel"
        game: game_id
        foo: Math.random().toString()
      }

      received: (data) ->
        if data.scoreboard_partial
          $('#scoreboard').replaceWith(data.scoreboard_partial)
          blink('.blink-after-move')
        if data.msg_type == 'move'
          window.game.drawStone data.color,
            x: data.x
            y: data.y
          if data.game_over
            alert("Game over - #{data.winner} wins!")
          if data.winning_coords
            window.game.markWin data.winning_coords, data.winner
        else if data.msg_type == 'join'
          $('#messages').append("<p class='errmsg'>#{data.user} joins the game. You can start!</p>")
        else if data.msg_type == 'leave'
          $('#messages').append("<p class='errmsg'>#{data.user} leaves the game</p>")

    )

$(document).on 'turbolinks:load', ->
  subscribe_game()

$ ->
  subscribe_game()
