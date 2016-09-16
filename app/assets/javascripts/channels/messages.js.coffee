subscribe_messages = ->
  room_id = $('#room_id').val()
  uuid = $('#user_uuid').val()

  if App.messages
    App.messages.unsubscribe()
    App.cable.subscriptions.remove(App.messages)
    App.messages = undefined

  if room_id && uuid && !App.messages
    App.messages = App.cable.subscriptions.create(
      {
        channel: 'MessagesChannel'
        room: room_id
        user: uuid
        foo: Math.random().toString() # no fucking idea why, but without this,
                                      # after removing and re-creating a subscription, all the
                                      # previously removed ones magically come back :/
      }

      received: (data) ->
        $('#messages').removeClass('hidden')
        @renderMessage(data)

      renderMessage: (data) ->
        if data.msg_type == 'new_game'
          if data.uuid == uuid
            Turbolinks.visit("/games/#{data.game_id}")
          else
            $('.no-games').hide()
            $('#games > .row').append(data.partial)
        else if data.msg_type == 'update_game'
          $("[data-game='#{data.game_id}']").replaceWith(data.partial)
        else if data.msg_type == 'delete_game'
          $("[data-game='#{data.game_id}']").remove()
          if $('.game-cell').length == 0
            $('.no-games').show()
        else
          $('#messages').append("<p><b>#{data.user}</b>: #{data.message}</p>")
          window.scroll_msgs_down()

      disconnected: (data) ->
        alert 'Connection lost, will try to reconnect automatically'
        subscribe_messages()
    )

$ ->
  window.scroll_msgs_down()
  subscribe_messages()



$(document).on 'turbolinks:load', ->
  window.scroll_msgs_down()
  subscribe_messages()
