@App.directive('mnoeProductPricingPrices', (ProvisioningHelper) ->
  restrict: 'E'
  scope: {
    subscription: '<',
    selectedCurrency: '<'
  },
  templateUrl: 'app/views/provisioning/product-pricing-price.html',
  link: (scope) ->
    scope.pricedPlan = ProvisioningHelper.pricedPlan
)
