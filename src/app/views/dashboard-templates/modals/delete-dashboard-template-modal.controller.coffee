@App.controller 'deleteDashboardTemplateCtrl', ($scope, $uibModalInstance, dashboardTemplateId, MnoeDashboardTemplates, toastr) ->
  'ngInject'

  $scope.close = ->
    $uibModalInstance.close(false)

  $scope.delete = ->
    $scope.isLoading = true
    MnoeDashboardTemplates.delete(dashboardTemplateId).then(
      (success) ->
        toastr.success('mnoe_admin_panel.dashboard.dashboard_templates.widget.list.toastr.deleted.successfully')
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.dashboard_templates.widget.list.toastr.deleted.error')
    ).finally(
      ->
        $scope.isLoading = false
        $uibModalInstance.close(true)
    )

  return
