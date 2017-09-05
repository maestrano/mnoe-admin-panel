@App.controller 'SettingsGeneralController', (toastr, CONFIG_JSON_SCHEMA, MnoeTenant) ->
  'ngInject'
  vm = this

  vm.settingsModel = {}
  vm.settingsSchema = CONFIG_JSON_SCHEMA

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

  # Load config from the Tenant
  loadConfig = ->
    MnoeTenant.get().then(
      (response) ->
        vm.settingsModel = response.data.frontend_config
    )

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
