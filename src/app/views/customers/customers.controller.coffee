@App.controller 'CustomersController', ($scope, $uibModal, MnoeAdminConfig, MnoeUsers, MnoeOrganizations, MnoeObservables, OBS_KEYS) ->
  'ngInject'
  vm = this

  vm.users = {}
  vm.organizations = {}
  vm.invoices = {}
  vm.isRegistrationEnabled = MnoeAdminConfig.isRegistrationEnabled()
  vm.isCustomerBatchImportEnabled = MnoeAdminConfig.isCustomerBatchImportEnabled()

  # Display user invitation modal
  vm.inviteUserModal = () ->
    $uibModal.open(
      templateUrl: 'app/views/customers/invite-user-modal/invite-user.html'
      controller: 'InviteUserController'
      controllerAs: 'vm'
    )

  updateUsersCounter = (response) ->
    vm.users.totalCount = response.headers('x-total-count')
    return

  MnoeObservables.registerCb(OBS_KEYS.userChanged, updateUsersCounter)

  MnoeOrganizations.registerListChangeCb((promise) ->
    promise.then(
      (response) ->
        vm.organizations.totalCount = response.headers('x-total-count')
      )
  )

  MnoeOrganizations.count().then(
    (response) ->
      vm.organizations.nonDemoCount = response.data.non_demo_count
  )

  $scope.$on('$destroy', () ->
    MnoeObservables.unsubscribe(OBS_KEYS.userChanged, updateUsersCounter)
  )

  return
