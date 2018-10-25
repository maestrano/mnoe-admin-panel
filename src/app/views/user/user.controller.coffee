@App.controller 'UserController', ($stateParams, MnoeUsers, MnoeAdminConfig, MnoeCurrentUser, UserRoles) ->
  'ngInject'
  vm = this

  # Get the user
  MnoeUsers.get($stateParams.userId).then(
    (response) ->
      vm.user = response.data
      countryCode = vm.user.phone_country_code
      phone = vm.user.phone
      if phone && countryCode
        vm.user.phone = '+' + countryCode + phone
  )

  vm.isAdminDashboardViewingEnabled = MnoeAdminConfig.isAdminDashboardViewingEnabled()

  MnoeCurrentUser.getUser().then(
    (response) ->
      vm.isSupportAgent = UserRoles.isSupportAgent(response)
  )

  return
