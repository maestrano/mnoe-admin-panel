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

  @isSupportManager = (user) ->
    (user.admin_role == 'support')

  @supportRoleForUser = (user) ->
    MnoeAdminConfig.isSupportRoleEnabled() && user.admin_role == 'support'

  @supportDisabledClass = (user) ->
    if @isSupportManager(user) then 'support' else ''

  @supportRoleLoggedIn = (user) ->
    @isSupportManager(user) && $cookies.get("support_org_id")

  return @
