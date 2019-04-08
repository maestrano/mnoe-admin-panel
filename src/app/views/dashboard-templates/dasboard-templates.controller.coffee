@App.controller 'DashboardTemplatesController', ($state, ImpacDashboardsSvc, ImpacConfigSvc) ->
  'ngInject'
  vm = this

  # Reconfigure Impac to enable the dashboard designer
  ImpacConfigSvc.enableDashboardDesigner()

  vm.createDashboard = (dashboard) ->
    angular.merge(dashboard, { published: false })
    ImpacDashboardsSvc.create(dashboard).then(
      (savedDhb) ->
        $state.go('dashboard.dashboard-templates-show', dashboardId: savedDhb.id)
    )

  return
