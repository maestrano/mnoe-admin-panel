@App.controller 'StaffController', ($log, $stateParams, $window, $uibModal, toastr, MnoeCurrentUser, MnoeUsers, MnoeSubTenants, ADMIN_ROLES) ->
  'ngInject'
  vm = this
  vm.isSaving = false
  vm.adminRoles = ADMIN_ROLES

  vm.isAdmin = MnoeCurrentUser.user.admin_role == 'admin'

  # Get the user
  MnoeUsers.get($stateParams.staffId).then(
    (response) ->
      vm.staff = response.data
      vm.staff.subTenantName = ->
        _.find(vm.subTenants, (subTenant) -> subTenant.id == vm.staff.mnoe_sub_tenant_id).name
      vm.staff.adminRoleName = ->
        _.find(vm.adminRoles, (role) -> role.value == vm.staff.admin_role).label

      if(vm.staff.mnoe_sub_tenant_id)
        MnoeSubTenants.get(vm.staff.mnoe_sub_tenant_id).then((r) -> vm.staff.subTenants = r.data.sub_tenants)
  )
  MnoeSubTenants.list(null, null, null).then((response) -> vm.subTenants = response.data)

  vm.updateStaff = ->
    vm.isSaving = true
    MnoeUsers.updateStaff(vm.staff).then(
      () ->
        toastr.success("mnoe_admin_panel.dashboard.staff.update_staff.toastr_success", {extraData: { staff_name: "#{vm.staff.name} #{vm.staff.surname}"}})
      (error) ->
        toastr.error("mnoe_admin_panel.dashboard.staff.update_staff.toastr_error", {extraData: { staff_name: "#{vm.staff.name} #{vm.staff.surname}"}})
        $log.error("An error occurred while updating staff:", error)
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
