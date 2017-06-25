@App.controller 'SettingsController', ($timeout, $window, CONFIG_JSON_SCHEMA, MnoeTenant) ->
  'ngInject'
  vm = this

  # vm.isLoading = false

  vm.settingsModel = {}
  vm.settingsSchema = CONFIG_JSON_SCHEMA
  vm.settingsForm = [
    "*",
    {
      type: "submit"
      title: "Save"
    }
  ]

#  vm.settingsForm = [
#    {
#      type: "tabs"
#      tabs: [
#        {
#          title: "Admin Panel"
#          items: ["admin_panel"]
#        }
#        {
#          title: "Dashboard"
#          items: ["*"]
#        }
#      ]
#    }
#    {
#      type: "actions"
#      items: [
#        type: "submit"
#        title: "Save"
#      ]
#    }
#  ]

  MnoeTenant.get().then(
    (response) ->
      vm.settingsModel = response.data.frontend_config
  )

  vm.saveSettings = (form) ->
#    vm.isLoading = true
    MnoeTenant.update(vm.settingsModel).then(
      ->
        $timeout(->
          $window.location.reload()
        , 2000)
      ->
#        vm.isLoading = false
        console.log("Error")
    )

  return
