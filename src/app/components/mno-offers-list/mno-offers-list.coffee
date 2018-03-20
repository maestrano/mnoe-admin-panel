#
# Nested Table Expand Directive
#

@App.directive('mnoOffersList', ($translate, $filter) ->
  restrict: 'AE'
  scope: {
    offers: '='
    markup: '='
  },
  templateUrl: 'app/components/mno-offers-list/mno-offers-list.html',
  link: (scope, elem, attrs) ->
    scope.formatPrice = (priceHash) ->
      if priceHash.price_cents then priceHash.currency + ' ' + inDollars(priceHash.price_cents) else '-'

    scope.formatFinalPrice = (priceHash) ->
      if scope.markup && priceHash.price_cents
        price = inDollars(priceHash.price_cents) + (inDollars(priceHash.price_cents) * scope.markup)
        priceHash.currency + ' ' + $filter('number')(price, 2)
      else
        scope.formatPrice(priceHash)

    scope.pricingType = (offer) ->
      switch offer.pricing_type
        when 'recurring'
          offer.per_unit + " / " + offer.per_duration
        when 'payg'
          $translate.instant("mnoe_admin_panel.dashboard.product_markups.offers.modal.usage_based")
        when 'one_off'
          $translate.instant("mnoe_admin_panel.dashboard.product_markups.offers.modal.one_off")

    inDollars = (val) ->
      parseInt(val) / 100.0
)
