@App.controller 'SettingsController', ($timeout, $window, CONFIG_JSON_SCHEMA, MnoeTenant) ->
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
      type: "actions"
      items: [
        type: "submit"
        title: "Save"
      ]
    }
  ]

  MnoeTenant.get().then(
    (response) ->
      vm.settingsModel = response.data.frontend_config
  )

  vm.saveSettings = (form) ->
    MnoeTenant.update(vm.settingsModel).then(
      ->
        $timeout(->
          $window.location.reload()
        , 2000)
      ->
        console.log("Error")
    )

  return
