@App.controller 'CreateStaffController', ($filter, $stateParams, $log, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, ADMIN_ROLES) ->
  'ngInject'
  vm = this

  vm.admin_roles = ADMIN_ROLES

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeUsers.addStaff(vm.user).then(
      (success) ->
        # Send an email to the new staff
        sendConfirmationEmail(vm.user)
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.staff.add_staff.modal.toastr_error', {extraData: { user_name: "#{vm.user.name} #{vm.user.surname}" }})
        $log.error("An error occurred:", error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  sendConfirmationEmail = (user) ->
    MnoeUsers.sendSignupEmail(user.email).then(
      (success) ->
        toastr.success('mnoe_admin_panel.dashboard.staff.add_staff.modal.toastr_success', {extraData: { user_name: "#{vm.user.name} #{vm.user.surname}" }})
        # Close the modal returning the item to the parent window
        $uibModalInstance.close(success.data)
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.staff.add_staff.modal.toastr_error_email', {extraData: { user_name: user.email }})
        $log.error("An error occurred:", error)

        # Remove the staff that has been added
        MnoeUsers.removeStaff(vm.user.id).then(
          () ->
          (error) ->
            $log.error("An error occurred while deleting the user:", error)
        )
    )

  return
