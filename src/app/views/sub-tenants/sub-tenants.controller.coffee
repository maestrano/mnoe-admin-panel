@App.controller 'SubTenantsController', ($stateParams, $window, $uibModal, MnoeSubTenants) ->
  'ngInject'
  vm = this

# Display sub Tenant creation modal
  vm.createModal = ->
    $uibModal.open(
      templateUrl: 'app/views/sub-tenants/create-sub-tenant-modal/create-sub-tenant.html'
      controller: 'CreateSubTenantController'
      controllerAs: 'vm'
    )


  # Get the user
  MnoeSubTenants.get($stateParams.subTenantId).then(
    (response) ->
      vm.subTenant = response.data
  )
  return
