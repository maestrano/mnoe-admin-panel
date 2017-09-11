@App.controller 'SettingsPluginsController', ($translate, toastr, MnoeTenant) ->
  vm = this

  vm.schema = {}
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
          "startEmpty": true,
          "items": [
            "payment_gateways[].name",
            "payment_gateways[].provider.adapter",
            {
              'type': 'conditional',
              'condition': 'vm.model.payment_gateways[arrayIndex].provider.adapter == "braintree"',
              'items': [
                {key: 'payment_gateways[].provider.config.merchant_id', "required": true},
                {key: 'payment_gateways[].provider.config.public_key', "required": true},
                {key: 'payment_gateways[].provider.config.private_key', "required": true}
              ]
            },
            {
              'type': 'conditional',
              'condition': 'vm.model.payment_gateways[arrayIndex].provider.adapter == "eway"',
              'items': [
                {key: 'payment_gateways[].provider.config.login', "required": true},
                {key: 'payment_gateways[].provider.config.username', "required": true},
                {key: 'payment_gateways[].provider.config.password', "required": true}
              ]
            },
            'payment_gateways[].accounts'
          ]
        }
      ]
    }
  ]

  # Load config from the Tenant
  loadConfig = ->
    MnoeTenant.get().then(
      (response) ->
        vm.model = response.data.plugins_config
        vm.schema = response.data.plugins_config_schema
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
