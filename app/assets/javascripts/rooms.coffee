$ ->
  $('#new_message').bind 'ajax:success', (e, xhr, status) ->
    $('#message_content').val('')
