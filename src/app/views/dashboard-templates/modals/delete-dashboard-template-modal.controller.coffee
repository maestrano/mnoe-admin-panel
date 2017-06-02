@App.controller 'deleteDashboardTemplateCtrl', ($scope, $uibModalInstance, dashboardTemplate, MnoeDashboardTemplates) ->
  'ngInject'

  $scope.close = ->
    $uibModalInstance.close()

  $scope.delete = ->
    $scope.isLoading = true
    MnoeDashboardTemplates.delete(dashboardTemplate).then(
      (response) ->
    ).finally(-> $uibModalInstance.close()
    $scope.isLoading = false )

  return
