subscribe_private = ->
  uuid = $('#user_uuid').val()

  if uuid && !App.private
    console.log "Creating App.private, uuid #{uuid}"

    App.private = App.cable.subscriptions.create(
      {
        channel: 'PrivateChannel'
        user: uuid
      }
      
      received: (data) ->
        alert(data.message) # TODO something more sophisticated
    )

$(document).on 'turbolinks:load', ->
  subscribe_private()

$ ->
  subscribe_private()