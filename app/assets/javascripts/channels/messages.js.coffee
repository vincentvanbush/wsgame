$ ->
  room_id = $('#room_id').val()
  uuid = $('#user_uuid').val()

  App.messages = App.cable.subscriptions.create(
    {
      channel: 'MessagesChannel'
      room: room_id
      user: uuid
    }

    received: (data) ->
      $('#messages').removeClass('hidden')
      @renderMessage(data)

    renderMessage: (data) ->
      if data.msg_type == 'new_game'
        $('#games > .row').append(data.partial)
      else if data.msg_type == 'update_game'

      else if data.msg_type == 'delete_game'
        $("[data-game='#{data.game_id}']").remove()
      else
        $('#messages').append("<p><b>#{data.user}</b>: #{data.message}</p>")
  )
