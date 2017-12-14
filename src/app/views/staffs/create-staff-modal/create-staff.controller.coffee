@App.controller 'CreateStaffController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, MnoeAdminConfig) ->
  'ngInject'
  vm = this

  vm.admin_roles = MnoeAdminConfig.adminRoles()
  vm.staffAlreadyExists = false
  vm.staff = null

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeUsers.search(email: vm.user.email).then(
      (success) ->
        vm.staffAlreadyExists = success.data.length > 0
        vm.staff = if vm.staffAlreadyExists
                     {
                       id: success.data[0].id,
                       admin_role: vm.user.admin_role,
                       name: success.data[0].name,
                       surname: success.data[0].surname
                     }
                   else
                     vm.user
        vm.addStaff() unless vm.staffAlreadyExists
      (error) ->
        vm.showError()
    ).finally(-> vm.isLoading = false)

  vm.addStaff = () ->
    vm.isLoading = true
    method = if vm.staff == vm.user then 'addStaff' else 'updateStaff'
    MnoeUsers[method](vm.staff).then(
      (success) ->
        toastr.success("mnoe_admin_panel.dashboard.staffs.add_staff.modal.toastr_success", {extraData: {staff_name: "#{vm.staff.name} #{vm.staff.surname}"}})
        # Close the modal returning the item to the parent window
        $uibModalInstance.close(success.data)
      (error) ->
        vm.showError()
    ).finally(-> vm.isLoading = false)

  vm.showError = () ->
    toastr.error('mnoe_admin_panel.dashboard.staffs.add_staff.modal.toastr_error', {extraData: { staff_name: "#{vm.user.name} #{vm.user.surname}" }})
    $log.error("An error occurred:", error)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
