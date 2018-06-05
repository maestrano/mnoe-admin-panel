@App.directive('mnoeProductPricingPrice', () ->
  restrict: 'E'
  scope: {
    subscription: '<',
    selectedCurrency: '<'
  },
  templateUrl: 'app/views/provisioning/product-pricing-price.html'
)
