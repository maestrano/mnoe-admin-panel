@App.controller 'SettingsController', (toastr, CONFIG_JSON_SCHEMA, MnoeTenant) ->
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
    {
      type: 'actions'
      items: [{
        type: 'button'
        title: 'Cancel'
        style: 'btn-danger'
        onClick: 'vm.cancel(settingsForm)'
      }, {
        type: 'submit'
        title: 'Save'
        style: 'btn-primary'
      }]
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

  vm.saveSettings = (form) ->
    MnoeTenant.update(vm.settingsModel).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.settings.save.toastr_success')

      ->
        toastr.error('mnoe_admin_panel.dashboard.settings.save.toastr_error')
    )

  return
