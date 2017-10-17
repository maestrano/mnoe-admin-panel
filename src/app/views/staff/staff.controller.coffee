@App.controller 'StaffController', ($scope, $log, $stateParams, $window, $uibModal, toastr, MnoConfirm, MnoeAdminConfig, MnoeCurrentUser, MnoeUsers, MnoeSubTenants) ->
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
      if vm.staff.sub_tenant_id
        MnoeSubTenants.get(vm.staff.sub_tenant_id).then(
          (result) ->
            vm.staff.subTenantName = result.data.name
            # Linking initial-value to vm.staff.subTenantName is not working
            # Setting value on the selector
            $scope.$broadcast('angucomplete-alt:changeInput', 'sub-tenant-selector', result.data.name)
        )
      vm.staff.admin_role_was = vm.staff.admin_role
      vm.staff.adminRoleName = ->
        _.find(vm.adminRoles, (role) -> role.value == vm.staff.admin_role).label
  )

  vm.searchSubTenants = (search, _timeoutPromise) ->
    return MnoeSubTenants.list(vm.nbItems, 0, 'name', {'where[name.like]' : search + '%'})

  vm.subTenantSelected = (subTenant) ->
    if subTenant
      vm.staff.sub_tenant_id = subTenant.originalObject.id
      console.log(vm.staff.sub_tenant_id)

  vm.clearSubTenantInput =() ->
    $scope.$broadcast('angucomplete-alt:clearInput', 'sub-tenant-selector')
    vm.staff.sub_tenant_id = null

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
