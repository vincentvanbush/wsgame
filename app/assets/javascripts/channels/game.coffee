$ ->
  game_id = $('#game_id').val()

  if game_id
    App.game = App.cable.subscriptions.create(
      {
        channel: "GameChannel"
        game: game_id
      }

      received: (data) ->
        alert("x=#{data.x} y=#{data.y}") # TODO something more sophisticated
    )