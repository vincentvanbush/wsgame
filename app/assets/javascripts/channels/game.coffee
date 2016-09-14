$ ->
  game_id = $('#game_id').val()

  if game_id
    App.game = App.cable.subscriptions.create(
      {
        channel: "GameChannel"
        game: game_id
      }

      received: (data) ->
        window.game.drawStone data.color,
          x: data.x
          y: data.y
    )