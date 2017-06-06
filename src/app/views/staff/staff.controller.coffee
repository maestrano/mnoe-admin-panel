@App.controller 'StaffController', ($log, $stateParams, $window, $uibModal, MnoeUsers, MnoeSubTenants, toastr) ->
  'ngInject'
  vm = this
  vm.isSaving = false
  # Get the user
  MnoeUsers.get($stateParams.staffId).then(
    (response) ->
      vm.staff = response.data
      if(vm.staff.mnoe_sub_tenant_id)
        MnoeSubTenants.get(vm.staff.mnoe_sub_tenant_id).then((r) -> vm.staff.subTenants = r.data.sub_tenants)
  )
  MnoeSubTenants.list(null, null, null).then((response) -> vm.subTenants = response.data)

  vm.updateStaff = ->
    vm.isSaving = true
    MnoeUsers.updateStaff(vm.staff).then(
      () ->
        toastr.success("#{vm.staff.name} has been successfully updated.")
      (error) ->
        toastr.error("An error occurred while updating #{vm.staff.name}.")
        $log.error("An error occurred:", error)
    ).finally(-> vm.isSaving = false)

  vm.updateClientsModal = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/staff/update-staff-clients-modal/update-staff-clients.html'
      controller: 'UpdateStaffClientsController'
      controllerAs: 'vm',
      resolve: {staff: () -> vm.staff}
    )
    modalInstance.result.then(
      (clients) ->
        vm.staff.clients = clients
    )
  return
