@App.directive('mnoAddressInput', ->
  return {
    restrict: 'EA'
    templateUrl: 'app/components/mno-address/mno-address-input/mno-address-input.html',
    scope: {
      address: '='
    }

    controller: ($scope, VALID_COUNTRIES) ->
      $scope.validCountries = ->
        countries = VALID_COUNTRIES
        c.phone_prefix = "(#{c.alpha2}) +#{c.country_code}" for c in countries
        countries

      return
  }
)
