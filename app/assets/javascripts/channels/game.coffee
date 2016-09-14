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
        window.game.drawStone data.color,
          x: data.x
          y: data.y
        if data.game_over
          alert("Game over - #{data.winner} wins!")
    )

$(document).on 'turbolinks:load', ->
  subscribe_game()

$ ->
  subscribe_game()