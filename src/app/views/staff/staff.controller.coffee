@App.controller 'StaffController', ($log, $stateParams, $window, $uibModal, toastr, MnoConfirm, MnoeAdminConfig, MnoeCurrentUser, MnoeUsers, MnoeSubTenants) ->
  'ngInject'
  vm = this
  vm.isSaving = false
  vm.adminRoles = MnoeAdminConfig.adminRoles()
  vm.clientsFilterParams = {'where[account_managers.id]': $stateParams.staffId}

  MnoeCurrentUser.getUser().then( ->
    vm.isAdmin = MnoeCurrentUser.user.admin_role == 'admin'
  )

  vm.isSubTenantEnabled = MnoeAdminConfig.isSubTenantEnabled()

  # Get the user
  MnoeUsers.get($stateParams.staffId).then(
    (response) ->
      vm.staff = response.data
      vm.staff.admin_role_was = vm.staff.admin_role
      vm.staff.subTenantName = ->
        _.find(vm.subTenants, (subTenant) -> subTenant.id == vm.staff.sub_tenant_id).name
      vm.staff.adminRoleName = ->
        _.find(vm.adminRoles, (role) -> role.value == vm.staff.admin_role).label
  )
  # Temporary solution, does not scale if there is more than 50 subtenants
  MnoeSubTenants.list(null, null, null).then((response) -> vm.subTenants = response.data)

  vm.updateStaff = ->
    vm.isSaving = true

    updateStaffAction = ->
      MnoeUsers.updateStaff(vm.staff).then(
        (response) ->
          vm.staff = response.data.user
          vm.staff.admin_role_was = vm.staff.admin_role
          toastr.success("mnoe_admin_panel.dashboard.staff.update_staff.toastr_success", {extraData: { staff_name: "#{vm.staff.name} #{vm.staff.surname}"}})
        (error) ->
          toastr.error("mnoe_admin_panel.dashboard.staff.update_staff.toastr_error", {extraData: { staff_name: "#{vm.staff.name} #{vm.staff.surname}"}})
          $log.error("An error occurred while updating staff:", error)
      ).finally(-> vm.isSaving = false)

    if vm.staff.admin_role_was == 'staff' &&  vm.staff.admin_role != 'staff' && vm.staff.client_ids.length
      # Ask for confirmation if the user is updated to admin or division admin as his clients will be cleared
      modalOptions =
        closeButtonText: 'mnoe_admin_panel.dashboard.staff.update_staff_role.cancel'
        actionButtonText: 'mnoe_admin_panel.dashboard.staff.update_staff_role.action'
        headerText: 'mnoe_admin_panel.dashboard.staff.update_staff_role.proceed'
        bodyText: 'mnoe_admin_panel.dashboard.staff.update_staff_role.perform'
      MnoConfirm.showModal(modalOptions).then(updateStaffAction).finally(-> vm.isSaving = false)
    else
      updateStaffAction()

  vm.updateClientsModal = ->
    $uibModal.open(
      templateUrl: 'app/views/staff/update-staff-clients-modal/update-staff-clients.html'
      controller: 'UpdateStaffClientsController'
      controllerAs: 'vm',
      resolve: {staff: () -> vm.staff}
    )

  return
