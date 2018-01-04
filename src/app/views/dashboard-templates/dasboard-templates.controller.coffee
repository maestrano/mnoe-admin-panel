@App.controller 'DashboardTemplatesController', ($state, ImpacDashboardsSvc) ->
  'ngInject'
  vm = this

  vm.createDashboard = (dashboard) ->
    angular.merge(dashboard, { published: false })
    ImpacDashboardsSvc.create(dashboard).then(
      (savedDhb) ->
        $state.go('dashboard.dashboard-templates-show', dashboardId: savedDhb.id)
    )

  return
