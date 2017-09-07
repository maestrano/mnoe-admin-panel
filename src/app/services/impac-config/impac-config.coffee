@App.service 'ImpacConfigSvc' , ($log, $q, MnoeCurrentUser, MnoeOrganizations) ->
  _self = @

  @getUserData = ->
    MnoeCurrentUser.getUser()

  @getOrganizations = ->
    userOrgsPromise = MnoeCurrentUser.getUser().then(
      (user) ->
        userOrgs = user.organizations
        if _.isEmpty(userOrgs)
          $log.error(err = { message: "Unable to retrieve user organizations" })
          $q.reject(err)
        else
          firstOrgId = userOrgs[0].id
          $q.resolve({ organizations: userOrgs, currentOrgId: firstOrgId })
    )

  return
