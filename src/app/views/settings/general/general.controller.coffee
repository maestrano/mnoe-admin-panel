@App.controller 'SettingsGeneralController', ($q, toastr, MnoeTenant, MnoeMarketplace) ->
  'ngInject'
  vm = this

  vm.settingsModel = {}
  vm.settingsSchema = {}

  vm.settingsForm = [
    {
      type: "tabs"
      tabs: [
        {
          title: "System"
          items: ["system"]
        }
        {
          title: "Dashboard"
          items: ["dashboard"]
        }
        {
          title: "Admin Panel"
          items: ["admin_panel"]
        }
      ]
    }
  ]

  # Remove apps which are no longer enabled
  validateAppList = (appNidList) ->
    if vm.settingsModel?.dashboard?.public_pages?
      publicPagesConf = vm.settingsModel.dashboard.public_pages
      publicPagesConf.applications = _.intersection(publicPagesConf.applications, appNidList)
      publicPagesConf.highlighted_applications = _.intersection(publicPagesConf.highlighted_applications, appNidList)

  # Load config from the Tenant
  loadConfig = ->
    vm.isLoading = true
    $q.all(tenant: MnoeTenant.get(), marketplace: MnoeMarketplace.getApps()).then(
      (response) ->
        vm.settingsModel = response.tenant.data.frontend_config
        vm.settingsSchema = response.tenant.data.config_schema
        validateAppList(_.map(response.marketplace.data.apps, 'nid'))
    ).finally(-> vm.isLoading = false)

  loadConfig()

  vm.cancel = (form) ->
    vm.settingsModel = {}
    form.$setPristine()
    loadConfig()

  vm.saveSettings = () ->
    vm.isLoading = true
    MnoeTenant.update(vm.settingsModel).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.settings.save.toastr_success')
      ->
        toastr.error('mnoe_admin_panel.dashboard.settings.save.toastr_error')
    ).finally(-> vm.isLoading = false)

  return
