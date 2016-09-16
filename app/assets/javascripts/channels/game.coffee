window.blink = (selector, counter = 0) ->
  return if counter >= 10
  if counter == 0
    $(selector).stop()
    clearTimeout(window.blinkTimeout) if window.blinkTimeout
    $(selector).css('opacity', '1')
  new_opacity = if $(selector).css('opacity') == '1'
                  '0'
                else
                  '1'
  $('.blink-after-move').animate
    opacity: new_opacity
    100
    -> window.blinkTimeout = setTimeout(->
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
          window.notifSound.play()
          window.game.drawStone data.color,
            x: data.x
            y: data.y
          if data.winning_coords
            window.game.markWin data.winning_coords, data.winner
          if data.game_over
            $('#messages').append("<p class='errmsg'>#{data.user} (#{data.winner}) wins the game! Click Replay to start again.</p>")
            $('.game-leave-link').hide()
            $('.game-restart-link').show()
        else if data.msg_type == 'join'
          window.notifSound.play()
          $('#messages').append("<p class='errmsg'>#{data.user} joins the game. You can start!</p>")
        else if data.msg_type == 'leave'
          window.notifSound.play()
          $('#messages').append("<p class='errmsg'>#{data.user} leaves the game</p>")
        else if data.msg_type == 'restart'
          window.game.drawBoard()
          window.notifSound.play()
          $('#messages').append("<p class='errmsg'>Replaying - let's go and have fun!</p>")
          $('.game-leave-link').show()
          $('.game-restart-link').hide()
    )

$(document).on 'turbolinks:load', ->
  subscribe_game()

$ ->
  subscribe_game()
