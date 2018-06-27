@App.service 'UserRoles', ($translate, $cookies, USER_ROLES, MnoeAdminConfig) ->
  _self = @

  @availableRoles = _.map(USER_ROLES, 'value')

  @availableRolesForOptions = _.map((USER_ROLES), (role) ->
    value: role.value,
    translatedLabel: $translate.instant(role.label)
  )

  @keyFromRole = (role) ->
    _.find(USER_ROLES, 'value', role).label

  @isAccountManager = (user) ->
    (user.admin_role == 'staff')

  @supportRoleForUser = (user) ->
    MnoeAdminConfig.isSupportRoleEnabled() && user.admin_role == 'support'

  return @
