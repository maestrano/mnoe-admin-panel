@App.controller 'SupportController', (toastr, MnoeAdminConfig) ->
  'ngInject'
  vm = this

  unless MnoeAdminConfig.isSupportRoleEnabled()
    toastr.error('mnoe_admin_panel.dashboard.home.support.toastr_error')

  return
