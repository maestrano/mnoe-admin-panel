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

  updateUsersCounter = () ->
    MnoeUsers.metrics().then(
      (response) ->
        vm.users.metrics = response.data.metrics
    )

  MnoeObservables.registerCb(OBS_KEYS.userChanged, updateUsersCounter)

  updateOrganizationsCounter = () ->
    MnoeOrganizations.count().then(
      (response) ->
        vm.organizations.kpi = response.data
    )

  MnoeObservables.registerCb(OBS_KEYS.orgChanged, updateOrganizationsCounter)

  $scope.$on('$destroy', () ->
    MnoeObservables.unsubscribe(OBS_KEYS.userChanged, updateUsersCounter)
    MnoeObservables.unsubscribe(OBS_KEYS.orgChanged, updateOrganizationsCounter)
  )

  return
