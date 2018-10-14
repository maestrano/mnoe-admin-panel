# Service for managing the users.
@App.service 'MnoeUsers', ($q, $log, MnoConfirm, MnoeAdminApiSvc, MnoeObservables, OBS_KEYS) ->
  _self = @

  @list = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    MnoeAdminApiSvc.all('users').getList(params).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.userChanged, response)
        response
    )

  @staffs = (limit, offset, sort, params = {}) ->
    # Require only users with an admin role (gets any role, not necessarly defined in the frontend)
    params['where[admin_role.not]'] = '' unless params['where[admin_role.in]']
    return _getStaffs(limit, offset, sort, params)

  @search = (terms, params = {}) ->
    params['terms'] = terms
    MnoeAdminApiSvc.all('users').getList(params)

  @get = (id) ->
    MnoeAdminApiSvc.one('users', id).get()

  @metrics = () ->
    MnoeAdminApiSvc.all('users').customGET('/metrics')

  # Create a user if not already existing, and add it to an organization
  # POST /mnoe/jpi/v1/admin/organizations/:orgId/users
  @addUser = (organization, user) ->
    MnoeAdminApiSvc.one('organizations', organization.id).all('/users').post({user: user})

  # Create a user if not already existing with an admin_role
  # POST /mnoe/jpi/v1/admin/users/
  @addStaff = (user) ->
    promise = MnoeAdminApiSvc.all('users').post({user: user}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.staffAdded, promise)
        response
    )

  @updateStaff = (user) ->
    promise = MnoeAdminApiSvc.one('users', user.id).patch({user: user}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.staffChanged, promise)
        response
    )

  @updateStaffClients = (user, changes) ->
    data = {user: changes}
    promise = MnoeAdminApiSvc.one('users', user.id).customPATCH(data, 'update_clients').then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.organizationChanged, promise)
        response
    )

  # Update the admin-role of a staff to nothing
  # UPDATE /mnoe/jpi/v1/admin/users/:id
  @removeStaff = (id) ->
    promise = MnoeAdminApiSvc.one('users', id).patch({admin_role: null}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.staffChanged, promise)
        response
    )

  # Invite a user to join an organization
  # POST /mnoe/jpi/v1/admin/organizations/:orgId/users/:userId/invite
  @inviteUser = (organization, user) ->
    MnoeAdminApiSvc.one('organizations', organization.id).one('users', user.id).doPOST({}, '/invites')

  @requestAccess = (user) ->
    MnoeAdminApiSvc.one('users', user.id).doPOST({}, 'user_access_requests')

  # Send an email to a user with the link to the registration page
  # POST /mnoe/jpi/v1/admin/users/signup_email
  @sendSignupEmail = (email) ->
    MnoeAdminApiSvc.all('/users').doPOST({user: {email: email}}, 'signup_email')

  @updateUserRole = (organization, user) ->
    MnoeAdminApiSvc.one('/organizations', organization.id).customPUT({member: user}, '/update_member')

  @removeUserFromOrganization = (organization, user) ->
    data = { member: user }
    MnoeAdminApiSvc.one('organizations', organization.id).doPUT(data, '/remove_member')

  @loginSupport = (user, organization_external_id) ->
    MnoeAdminApiSvc.one('users', user.id).customPOST({ organization_external_id: organization_external_id}, 'login_with_org_external_id')

  _getStaffs = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    return MnoeAdminApiSvc.all("users").getList(params)

  return @
