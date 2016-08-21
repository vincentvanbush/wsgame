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
      $('#messages').append(@renderMessage(data))

    renderMessage: (data) ->
      "<p><b>#{data.user}</b>: #{data.message}</p>"
  )
