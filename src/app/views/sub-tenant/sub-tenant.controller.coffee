@App.controller 'SubTenantController', ($stateParams, $window,  $uibModal, MnoeSubTenants) ->
  'ngInject'
  vm = this

  # Get the user
  MnoeSubTenants.get($stateParams.subTenantId).then(
    (response) ->
      vm.subTenant = response.data
  )

  vm.updateClientsModal = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/sub-tenant/update-clients-modal/update-clients.html'
      controller: 'UpdateClientsController'
      controllerAs: 'vm',
      resolve: {subTenant: () -> vm.subTenant}
    )
    modalInstance.result.then(
      (clients) ->
        vm.subTenant.clients = clients
    )


  vm.updateAccountManagerModal = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/sub-tenant/update-account-managers-modal/update-account-managers.html'
      controller: 'UpdateAccountManagersController'
      controllerAs: 'vm',
      resolve: {subTenant: () -> vm.subTenant}
    )
    modalInstance.result.then(
      (account_managers) ->
        vm.subTenant.account_managers = account_managers
    )

  return
