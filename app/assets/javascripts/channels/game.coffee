$(document).on 'turbolinks:load', ->
  game_id = $('#game_id').val()

  if App.game
    App.cable.subscriptions.remove(App.game)

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