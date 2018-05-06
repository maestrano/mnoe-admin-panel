@App.directive('mnoAddressLine', ->
  return {
    restrict: 'EA'
    templateUrl: 'app/components/mno-address/mno-address-line/mno-address-line.html',
    scope: {
      address: '='
    }

    controller: ($scope) ->
      displayAttrs = ['street', 'city', 'state_code', 'postal_code', 'country_code']
      $scope.displayAddress = _.map(displayAttrs, (attr) -> $scope.address[attr]).join(', ')
      return
  }
)
