@App.service 'UserRoles', (USER_ROLES, $translate) ->
  _self = @

  @availableRoles = _.map(USER_ROLES, 'value')

  @availableRolesForOptions = _.map((USER_ROLES), (role) ->
    value: role.value,
    translatedLabel: $translate.instant(role.label)
  )

  @keyFromRole = (role) ->
    _.find(USER_ROLES, 'value', role).label

  return @
