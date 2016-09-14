$(document).on 'turbolinks:load', ->
  uuid = $('#user_uuid').val()

  if App.private
      App.cable.subscriptions.remove(App.private)

  if uuid
    App.private = App.cable.subscriptions.create(
      {
        channel: 'PrivateChannel'
        user: uuid
      }
      
      received: (data) ->
        alert(data.message) # TODO something more sophisticated
    )