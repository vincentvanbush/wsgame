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
        $('#scoreboard').replaceWith(data.scoreboard_partial) if data.scoreboard_partial
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
