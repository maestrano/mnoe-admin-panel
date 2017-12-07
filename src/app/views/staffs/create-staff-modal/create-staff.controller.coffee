@App.controller 'CreateStaffController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, MnoeAdminConfig) ->
  'ngInject'
  vm = this

  vm.admin_roles = MnoeAdminConfig.adminRoles()

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeUsers.addStaff(vm.user).then(
      (success) ->
        toastr.success("mnoe_admin_panel.dashboard.staffs.add_staff.modal.toastr_success", {extraData: {staff_name: "#{vm.user.name} #{vm.user.surname}"}})
        # Close the modal returning the item to the parent window
        $uibModalInstance.close(success.data)
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.staffs.add_staff.modal.toastr_error', {extraData: { staff_name: "#{vm.user.name} #{vm.user.surname}" }})
        $log.error("An error occurred:", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
