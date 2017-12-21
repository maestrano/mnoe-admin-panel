@App.controller 'SubTenantController', ($stateParams, $window,  $uibModal, MnoeSubTenants) ->
  'ngInject'
  vm = this

  vm.clientsFilterParams = {'where[sub_tenants.id]': $stateParams.subTenantId}
  vm.accountManagersFilterParams = {'where[sub_tenant.id]': $stateParams.subTenantId}

  # Get the user
  MnoeSubTenants.get($stateParams.subTenantId).then(
    (response) ->
      vm.subTenant = response.data
  )

  vm.updateClientsModal = ->
    $uibModal.open(
      templateUrl: 'app/views/sub-tenant/update-clients-modal/update-clients.html'
      controller: 'UpdateClientsController'
      controllerAs: 'vm',
      resolve: {subTenant: () -> vm.subTenant}
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
