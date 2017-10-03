@App.service 'IntercomSvc', ($window, MnoeCurrentUser, INTERCOM_ID) ->
  @init = () ->
    if $window.Intercom
      MnoeCurrentUser.getUser().then(
        (response) ->
          userData = {
            app_id: INTERCOM_ID,
            user_id: response.id,
            email: response.email,
            admin_role: response.admin_role,
            name: response.name,
            surname: response.surname,
            created_at: response.created_at,
            widget: {
              activator: "#IntercomDefaultWidget"
            }
          }

          # Add Intercom secure hash
          userData.user_hash = response.user_hash if response.user_hash

          $window.Intercom('boot', userData)
      )


  # Will update in every page change so intercom knows we're still active and load new messages
  @update = () ->
    $window.Intercom('update') if $window.Intercom

  # When user logs out, call to end the Intercom session and clear the cookie.
  @logOut = ->
    $window.Intercom('shutdown') if $window.Intercom

  return @
