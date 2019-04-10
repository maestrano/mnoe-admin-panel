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
  controller: ($window, toastr, MnoErrorsHandler, MnoeAdminConfig, MnoeUsers, MnoeCurrentUser, MnoConfirm, UserRoles) ->
    vm = this

    MnoeCurrentUser.getUser().then(
      (response) ->
        vm.isSupportAgent = UserRoles.isSupportAgent(response)
        vm.isImpersonationEnabled = MnoeAdminConfig.isImpersonationEnabled() && !vm.isSupportAgent
    )

    vm.impersonationStatus = ->
      if !vm.user.confirmed
        'unauthorized'
      else if vm.user.admin_role
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
      modalOptions =
        closeButtonText: 'mnoe_admin_panel.dashboard.users.widget.local_list.modal.cancel'
        actionButtonText: 'mnoe_admin_panel.dashboard.users.widget.local_list.request_access'
        headerText: 'mnoe_admin_panel.dashboard.users.widget.local_list.modal.request_access_title'
        bodyText: 'mnoe_admin_panel.dashboard.users.widget.local_list.modal.body'
        actionCb: () -> MnoeUsers.requestAccess(vm.user).then(
          () ->
            toastr.success('mnoe_admin_panel.dashboard.users.widget.local_list.request_access.toastr_success', {extraData: {username: "#{vm.user.name} #{vm.user.surname}"}})
            vm.user.access_request_status = 'requested'
          (error) ->
            toastr.error('mnoe_admin_panel.dashboard.users.widget.local_list.request_access.toastr_error', {extraData: {username: "#{vm.user.name} #{vm.user.surname}"}})
            MnoErrorsHandler.processServerError(error)
          )

      MnoConfirm.showModal(modalOptions)
    return
})
