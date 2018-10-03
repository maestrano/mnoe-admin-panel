@App.controller 'AppInstanceInfoModal', ($scope, $uibModalInstance, MnoAppsInstances, appInstance, organization) ->
  'ngInject'
  vm = this
  vm.appInstance = appInstance
  vm.organization = organization
  vm.syncStatus = appInstance.sync_status

  vm.closeModal = ->
    $uibModalInstance.close(true)

  vm.isConnected = MnoAppsInstances.isConnected(vm.appInstance)
  vm.canBeDataSynced = MnoAppsInstances.canBeDataSynced(vm.appInstance)

  return
