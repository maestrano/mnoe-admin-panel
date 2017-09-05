@App.controller 'SettingsPluginsController', ($translate, toastr, PLUGINS_CONFIG_SCHEMA, MnoeTenant) ->
  vm = this

  vm.schema = PLUGINS_CONFIG_SCHEMA
  vm.model = {}

  vm.form = [
    {
      "type": "fieldset",
      "title": "Payment Gateways",
      "items": [
        {
          "type": "help",
          "helpvalue": "To setup a custom payment gateway, simply add a new one below."
        },
        {
          "key": "payment_gateways",
          "type": "tabarray",
          "tabType": "top",
          "title": "{{ value.name || 'Gateway '+$index }}",
          "add": "New",
          "remove": "Delete",
          "style": {
            "remove": "btn-danger"
          },
          "startEmpty": true
        }
      ]
    }
  ]

  # Load config from the Tenant
  loadConfig = ->
    MnoeTenant.get().then(
      (response) ->
        vm.model = response.data.plugins_config
    )

  loadConfig()

  vm.cancel = (form) ->
    vm.model = {}
    form.$setPristine()
    loadConfig()

  vm.saveSettings = () ->
    vm.isLoading = true
    MnoeTenant.updatePluginsConfig(vm.model).then(
      ->
        toastr.success('mnoe_admin_panel.dashboard.settings.save.toastr_success')
      ->
        toastr.error('mnoe_admin_panel.dashboard.settings.save.toastr_error')
    ).finally(-> vm.isLoading = false)

  return
