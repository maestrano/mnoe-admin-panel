@App.controller 'AppInstanceInfoModal', ($scope, $uibModalInstance, MnoAppsInstances, appInstance, organization) ->
  'ngInject'
  vm = this
  vm.appInstance = appInstance
  vm.organization = organization
  vm.syncStatus = appInstance.sync_status

  vm.closeModal = ->
    $uibModalInstance.close(true)

  vm.isConnected = MnoAppsInstances.isConnected(vm.appInstance)
  vm.isConnectedTooltip = 'mnoe_admin_panel.dashboard.organization.app_info.connected.' + vm.isConnected + '.tooltip'

  vm.canBeDataSynced = MnoAppsInstances.canBeDataSynced(vm.appInstance)
  vm.canBeDataSyncedTooltyip = 'mnoe_admin_panel.dashboard.organization.app_info.data_syncable.' + vm.isConnected + '.tooltip'

  vm.syncStatusTooltip = 'mnoe_admin_panel.dashboard.organization.app_info.sync_status.' + vm.syncStatus?.status + '.tooltip'

  vm.progress = if vm.syncStatus?.progress
    vm.syncStatus.progress + '%'
  else
    'mnoe_admin_panel.dashboard.organization.app_info.progress.unavailable_tooltip'

  return
