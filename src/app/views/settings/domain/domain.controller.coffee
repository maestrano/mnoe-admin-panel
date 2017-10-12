@App.controller 'SettingsDomainController', ($filter, $scope, $window, toastr, MnoConfirm, MnoeTenant) ->
  'ngInject'
  vm = this
  vm.tenant = {}
  vm.originalTenant = {}
  vm.ssl = {}
  vm.originalSsl = {}
  vm.isLoading = true

  MnoeTenant.get().then(
    (response) ->
      vm.tenant = response.data
      vm.originalTenant = angular.copy(vm.tenant)
  ).finally(-> vm.isLoading = false)

  vm.showConfirmModal = () ->
    MnoConfirm.showModal(
      headerText: 'mnoe_admin_panel.dashboard.settings.modal.confirm.proceed'
      bodyText: 'mnoe_admin_panel.dashboard.settings.modal.confirm.perform'
      type: 'danger'
    )

  vm.uploadCerts = () ->
    vm.showConfirmModal().then(->
      vm.isCertSaving = true
      MnoeTenant.addSSLCerts(vm.ssl).then(
        ->
          vm.originalSsl = angular.copy(vm.ssl)
          toastr.success('mnoe_admin_panel.dashboard.settings.ssl.save.toastr_success')
        ->
          toastr.error('mnoe_admin_panel.dashboard.settings.ssl.save.toastr_error')
      ).finally(-> vm.isCertSaving = false)
    )

  vm.updateDomain = () ->
    vm.showConfirmModal().then( ->
      vm.isDomainSaving = true
      MnoeTenant.updateDomain(_.pick(vm.tenant, 'domain')).then(
        ->
          vm.originalTenant = angular.copy(vm.tenant)
          toastr.success('mnoe_admin_panel.dashboard.settings.domain.save.toastr_success')
        ->
          toastr.error('mnoe_admin_panel.dashboard.settings.domain.save.toastr_error')
      ).finally(-> vm.isDomainSaving = false)
    )

  # Handle unsaved changes notifications
  changedForm = () ->
    !(angular.equals(vm.originalTenant, vm.tenant) && angular.equals(vm.originalSsl, vm.ssl))

  locationChangeStartUnbind = $scope.$on('$stateChangeStart', (event) ->
    if changedForm()
      answer = confirm($filter('translate')('mnoe_admin_panel.dashboard.settings.modal.confirm.unsaved'))
      event.preventDefault() if (!answer)
  )

  $window.onbeforeunload = (e) ->
    if changedForm()
      true
    else
      undefined

  $scope.$on('$destroy', () ->
    $window.onbeforeunload = undefined
    locationChangeStartUnbind()
  )

  return
