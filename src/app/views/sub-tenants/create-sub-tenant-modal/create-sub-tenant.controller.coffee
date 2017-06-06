@App.controller 'CreateSubTenantController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeSubTenants, MnoErrorsHandler) ->
  'ngInject'
  vm = this

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeSubTenants.create(vm.subTenant).then(
      () ->
        toastr.success("#{vm.subTenant.name} has been successfully added.")
      (error) ->
        toastr.error("An error occurred while adding #{vm.subTenant.name}.")
        $log.error("An error occurred:", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')


  return
