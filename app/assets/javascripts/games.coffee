gameReady = ->
  $('.in-game-remove').on 'ajax:success', ->
    Turbolinks.visit("/rooms/#{$('#room_name').val()}")

$(document).on 'turbolinks:load', ->
  gameReady()
