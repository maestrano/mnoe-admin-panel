@App.directive('mnoAppFeatures', ->
  return {
    restrict: 'EA'
    templateUrl: 'app/components/mno-app-features/mno-app-features.html',
    scope: {
      app: '='
    }

    controller: ($scope) ->
      $scope.isSingleBilling = !!$scope.app.single_billing
      $scope.isDataSharing = !!$scope.app.is_connec_ready
      $scope.isSingleSignOn = !!$scope.app.add_on
      return
  }
)
