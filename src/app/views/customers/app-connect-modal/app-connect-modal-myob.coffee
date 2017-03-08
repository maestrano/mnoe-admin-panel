@App.controller 'ConnectMyobModalCtrl', ($window, $httpParamSerializer, $uibModalInstance, MnoAppsInstances, app) ->
  'ngInject'
  vm = this

  vm.app = app
  vm.form = {
    perform: true
    version: "essentials"
  }
  vm.versions = [
    {label: "mnoe_admin_panel.dashboard.customers.connect_app.myob.version_type.right_live", value: "account_right"},
    {label: "mnoe_admin_panel.dashboard.customers.connect_app.myob.version_type.essentials", value: "essentials"}]

  vm.connect = (form) ->
    $window.location.href = MnoAppsInstances.oAuthConnectPath(app, $httpParamSerializer(form))

  vm.close = ->
    $uibModalInstance.close()

  return

