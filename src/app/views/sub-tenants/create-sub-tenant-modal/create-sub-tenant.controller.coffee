@App.controller 'CreateSubTenantController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeSubTenants, MnoErrorsHandler) ->
  'ngInject'
  vm = this

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeSubTenants.create(vm.subTenant).then(
      (success) ->
        toastr.success("mnoe_admin_panel.dashboard.sub_tenants.create_sub_tenant.toastr_success", {extraData: {sub_tenant_name: vm.subTenant.name}})
        $uibModalInstance.close(success.data)
      (error) ->
        toastr.error("mnoe_admin_panel.dashboard.sub_tenants.create_sub_tenant.toastr_error", {extraData: {sub_tenant_name: vm.subTenant.name}})
        $log.error("An error occurred:", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
