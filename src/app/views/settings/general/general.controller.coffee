@App.controller 'SettingsGeneralController', ($translate, $scope, $window, $q, toastr, MnoConfirm, MnoeTenant, MnoeMarketplace) ->
  'ngInject'
  vm = this

  vm.settingsModel = {}
  vm.originalSettings = {}
  vm.settingsSchema = {}

  $translate([
    'mnoe_admin_panel.dashboard.settings.general.tabs.system',
    'mnoe_admin_panel.dashboard.settings.general.tabs.dashboard',
    'mnoe_admin_panel.dashboard.settings.general.tabs.admin_panel'
  ]).then(
    (translations) ->
      vm.settingsForm = [
        {
          type: "tabs"
          tabs: [
            {
              title: translations['mnoe_admin_panel.dashboard.settings.general.tabs.system']
              items: ["system"]
            }
            {
              title: translations['mnoe_admin_panel.dashboard.settings.general.tabs.dashboard']
              items: ["dashboard"]
            }
            {
              title: translations['mnoe_admin_panel.dashboard.settings.general.tabs.admin_panel']
              items: ["admin_panel"]
            }
          ]
        }
      ]
  )

  # Remove apps which are no longer enabled
  validateAppList = (appNidList, localProductNidList) ->
    if vm.settingsModel?.dashboard?.public_pages?
      publicPagesConf = vm.settingsModel.dashboard.public_pages
      publicPagesConf.applications = _.intersection(publicPagesConf.applications, appNidList)
      publicPagesConf.highlighted_applications = _.intersection(publicPagesConf.highlighted_applications, appNidList)
      publicPagesConf.local_products = _.intersection(publicPagesConf.local_products, appNidList)
      publicPagesConf.highlighted_local_products = _.intersection(publicPagesConf.highlighted_local_products, appNidList)

  # Load config from the Tenant
  loadConfig = ->
    vm.isLoading = true
    $q.all(tenant: MnoeTenant.get(), marketplace: MnoeMarketplace.getApps()).then(
      (response) ->
        vm.settingsModel = response.tenant.data.frontend_config
        vm.originalSettings = angular.copy(vm.settingsModel)
        vm.settingsSchema = response.tenant.data.config_schema
        validateAppList(_.map(response.marketplace.data.apps, 'nid'), _.map(_.filter(response.marketplace.data.products, (product) -> product.local), 'nid'))
    ).finally(-> vm.isLoading = false)

  loadConfig()

  vm.cancel = (form) ->
    vm.settingsModel = {}
    form.$setPristine()
    loadConfig()

  vm.saveSettings = () ->
    MnoConfirm.showModal(
      headerText: 'mnoe_admin_panel.dashboard.settings.modal.confirm.proceed'
      bodyText: 'mnoe_admin_panel.dashboard.settings.modal.confirm.perform'
      type: 'danger'
    ).then(->
      vm.isLoading = true
      MnoeTenant.update(vm.settingsModel).then(
        ->
          vm.originalSettings = angular.copy(vm.settingsModel)
          toastr.success('mnoe_admin_panel.dashboard.settings.save.toastr_success')
        ->
          toastr.error('mnoe_admin_panel.dashboard.settings.save.toastr_error')
      ).finally(-> vm.isLoading = false)
    )

  # Handle unsaved changes notifications
  changedForm = () ->
    !angular.equals(vm.settingsModel, vm.originalSettings)

  locationChangeStartUnbind = $scope.$on('$stateChangeStart', (event) ->
    if changedForm()
      answer = confirm($translate.instant('mnoe_admin_panel.dashboard.settings.modal.confirm.unsaved'))
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
