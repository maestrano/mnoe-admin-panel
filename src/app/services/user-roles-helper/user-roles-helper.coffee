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

  @isSupportAgent = (user) ->
    (user.admin_role == 'support')

  @supportRoleLoggedIn = (user) ->
    @isSupportAgent(user) && user.support_org_id

  @supportDisabledClass = (user) ->
    if @isSupportAgent(user) then 'support' else ''

  return @
