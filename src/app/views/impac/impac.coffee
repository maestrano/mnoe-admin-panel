@App.controller 'ImpacController', (action, $rootScope, $stateParams, $state, MnoeDashboardTemplates, ImpacDashboardsSvc) ->
  'ngInject'
  vm = this

  vm.createTemplate = ->
    vm.showImpac = false
    ImpacDashboardsSvc.load().then(
      (config) ->
        vm.currentDashboard = config.currentDashboard

        # Open Create Dashboard modal
        e = document.getElementById('module__dashboard-selector')
        s = angular.element(e).scope()
        modal = s.createDashboardModal
        modal.open()

        # Callbacks to display Impac! (or redirect to templates list) after the modal is closed
        modal.instance.result.then(
          (closed) ->
            vm.showImpac = true
          (dismissed) ->
            $state.go('dashboard.dashboard-templates')
        )
    )

  vm.editTemplate = ->
    vm.showImpac = true
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

  switch action.value
    when 'create'
      vm.createTemplate()
    when 'edit'
      vm.editTemplate()

  vm.toggleTemplatePublished = (id) ->
    MnoeDashboardTemplates.toggleTemplatePublished(id)

  return
