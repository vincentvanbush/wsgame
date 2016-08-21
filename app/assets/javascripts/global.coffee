$ ->
  @msgs = ->
    $('#messages')

  @scroll_msgs_down = ->
    @msgs().scrollTop(@msgs().prop('scrollHeight'))

  # Capture ajax errors in remote forms/links specified by .capture-error
  $('.capture-error').on 'ajax:error', (e, xhr, status) ->
    $('#messages').append("<p class='errmsg'>#{xhr.responseJSON.error}</p>")
