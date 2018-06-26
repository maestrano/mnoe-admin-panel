#
# Nested Table Expand Directive
#

@App.directive('mnoOffersList', ($translate, PricingHelper) ->
  restrict: 'AE'
  scope: {
    offers: '='
    markup: '='
  },
  templateUrl: 'app/components/mno-offers-list/mno-offers-list.html',
  link: (scope, elem, attrs) ->
    scope.formatPrice = (priceHash) ->
      PricingHelper.formatPrice(priceHash.price_cents, priceHash.currency)

    scope.formatFinalPrice = (priceHash) ->
      PricingHelper.formatFinalPrice(priceHash.price_cents, priceHash.currency, scope.markup)

    scope.displayPricing = (offer) ->
      offer.prices && !offer.quote_based
      
    scope.pricingType = (offer) ->
      switch offer.pricing_type
        when 'recurring'
          offer.per_unit + " / " + offer.per_duration
        when 'payg'
          $translate.instant("mnoe_admin_panel.dashboard.product_markups.offers.modal.usage_based")
        when 'one_off'
          $translate.instant("mnoe_admin_panel.dashboard.product_markups.offers.modal.one_off")
)
