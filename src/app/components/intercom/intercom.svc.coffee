@App.service 'IntercomSvc', ($window, INTERCOM_ID) ->
  @init = (user) ->
    if $window.Intercom
      userData = {
        app_id: INTERCOM_ID,
        user_id: user.id,
        email: user.email,
        admin_role: user.admin_role,
        name: user.name,
        surname: user.surname,
        created_at: user.created_at,
        widget: {
          activator: "#IntercomDefaultWidget"
        }
      }

      # Add Intercom secure hash
      userData.user_hash = user.user_hash if user.user_hash

      $window.Intercom('boot', userData)

  # Will update in every page change so intercom knows we're still active and load new messages
  @update = () ->
    $window.Intercom('update') if $window.Intercom

  # When user logs out, call to end the Intercom session and clear the cookie.
  @logOut = ->
    $window.Intercom('shutdown') if $window.Intercom

  return @
