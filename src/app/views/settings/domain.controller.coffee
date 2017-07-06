@App.controller 'SettingsDomainController', (toastr, MnoeTenant) ->
  'ngInject'
  vm = this
  vm.tenant = {}
  vm.ssl = {}
  vm.isLoading = true

  MnoeTenant.get().then(
    (response) ->
      vm.tenant = response.data
  ).finally(-> vm.isLoading = false)

  vm.uploadCerts = () ->
    vm.isCertSaving = true
    MnoeTenant.addSSLCerts(vm.ssl).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.settings.ssl.save.toastr_success')
      ->
        toastr.error('mnoe_admin_panel.dashboard.settings.ssl.save.toastr_error')
    ).finally(-> vm.isCertSaving = false)

  vm.updateDomain = () ->
    vm.isDomainSaving = true
    MnoeTenant.updateDomain(_.pick(vm.tenant, 'domain')).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.settings.domain.save.toastr_success')
      ->
        toastr.error('mnoe_admin_panel.dashboard.settings.domain.save.toastr_error')
    ).finally(-> vm.isDomainSaving = false)

  return
