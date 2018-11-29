@App.controller 'ImpacController', (
  $rootScope, $state, $stateParams
  MnoeDashboardTemplates, MnoeOrganizations, ImpacConfigSvc, ImpacDashboardsSvc
) ->
  'ngInject'
  vm = this
  vm.dashboardLoaded = false

  vm.designerMode = $state.current.data.dashboardDesigner
  vm.orgId = $stateParams.orgId

  if vm.designerMode != ImpacConfigSvc.dashboardDesigner
    ImpacConfigSvc.configureDashboardDesigner(vm.designerMode)

  $rootScope.$watch(
    ->
      vm.dashboardLoaded
    (loaded) ->
      if loaded
        dashboardId = parseInt($stateParams.dashboardId)
        ImpacDashboardsSvc.setCurrentDashboard(dashboardId)
        vm.currentDashboard = ImpacDashboardsSvc.getCurrentDashboard()
  )

  unless vm.callbackRegistered
    ImpacDashboardsSvc.dashboardChanged().then null, null, ->
      vm.dashboardLoaded = true
    vm.callbackRegistered = true

  vm.toggleTemplatePublished = (id) ->
    MnoeDashboardTemplates.toggleTemplatePublished(id)

  return
