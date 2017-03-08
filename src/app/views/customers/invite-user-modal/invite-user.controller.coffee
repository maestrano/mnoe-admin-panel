@App.controller 'InviteUserController', ($filter, $stateParams, $uibModalInstance, toastr, MnoeUsers, MnoErrorsHandler, USER_ROLES) ->
  'ngInject'
  vm = this

  vm.USER_ROLES = USER_ROLES

  vm.onSubmit = () ->
    vm.isLoading = true
    MnoeUsers.sendSignupEmail(vm.user.email).then(
      (success) ->
        toastr.success('mnoe_admin_panel.dashboard.customers.invite_user_modal.toastr_success', {extraData: {email: vm.user.email}})
        # Close the modal returning the item to the parent window
        $uibModalInstance.close(vm.user.email)
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.customers.invite_user_modal.toastr_error', {extraData: {email: vm.user.email}})
        MnoErrorsHandler.processServerError(error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
