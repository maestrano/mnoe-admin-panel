@App.controller 'ImpacController', ($rootScope, $stateParams, MnoeDashboardTemplates, ImpacDashboardsSvc) ->
  'ngInject'
  vm = this
  vm.dashboardLoaded = false

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
