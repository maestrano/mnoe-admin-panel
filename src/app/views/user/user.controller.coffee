@App.controller 'UserController', ($stateParams, MnoeUsers) ->
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
  return
