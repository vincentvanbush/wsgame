messages_subscribed = false
subscribe_messages = ->
  room_id = $('#room_id').val()
  uuid = $('#user_uuid').val()

  if room_id && uuid
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
          if data.uuid == uuid
            Turbolinks.visit("/games/#{data.game_id}")
          else
            $('#games > .row').append(data.partial)
        else if data.msg_type == 'update_game'
          # TODO
        else if data.msg_type == 'delete_game'
          $("[data-game='#{data.game_id}']").remove()
        else
          $('#messages').append("<p><b>#{data.user}</b>: #{data.message}</p>")
          window.scroll_msgs_down()
    )

$ ->
  @scroll_msgs_down()
  if App.messages
    App.cable.subscriptions.remove(App.messages)
  subscribe_messages()

$(document).on 'turbolinks:load', ->
  if App.messages
    App.cable.subscriptions.remove(App.messages)
  subscribe_messages()
