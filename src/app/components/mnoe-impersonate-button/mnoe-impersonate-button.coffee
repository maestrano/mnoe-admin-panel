@App.component('mnoeImpersonateButton', {
  templateUrl: 'app/components/mnoe-impersonate-button/mnoe-impersonate-button.html',
  bindings: {
    organizationId: '<'
    wrapperClassNames: '@'
    btnClassNames: '@'
    classNames: '@',
    user: '<',
  }
  controllerAs: 'vm'
  controller: ($window, toastr, MnoErrorsHandler, MnoeAdminConfig, MnoeUsers, $uibModal) ->
    vm = this
    vm.isImpersonationEnabled = MnoeAdminConfig.isImpersonationEnabled()

    vm.impersonationStatus = ->
      if vm.user.admin_role
        'disabled'
      else if MnoeAdminConfig.isImpersonationConsentRequired()
        switch vm.user.access_request_status
          when 'approved' then 'approved'
          when 'never_requested', 'expired', 'denied', 'revoked' then 'requestable'
          when 'requested' then 'requested'
      else
        'approved'

    # Impersonate the user
    vm.impersonateUser = () ->
      redirect = window.encodeURIComponent("#{location.pathname}#{location.hash}")
      url = "/mnoe/impersonate/user/#{vm.user.id}?redirect_path=#{redirect}"
      if vm.organizationId
        url = url + "&dhbRefId=#{vm.organizationId}"
      $window.location.href = url

    vm.openRequestModal = () ->
      modalInstance = $uibModal.open(
        component: "mnoeImpersonateModal",
        resolve:
          actionCb: () -> vm.requestAccess
      )

    vm.requestAccess = () ->
      MnoeUsers.requestAccess(vm.user).then(
        () ->
          toastr.success('mnoe_admin_panel.dashboard.users.widget.local_list.request_access.toastr_success', {extraData: {username: "#{vm.user.name} #{vm.user.surname}"}})
          vm.user.access_request_status = 'requested'
        (error) ->
          toastr.error('mnoe_admin_panel.dashboard.users.widget.local_list.request_access.toastr_error', {extraData: {username: "#{vm.user.name} #{vm.user.surname}"}})
          MnoErrorsHandler.processServerError(error)
      )

    return
})
