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
      priceHash.currency + ' ' + inDollars(priceHash.price_cents)

    scope.formatFinalPrice = (priceHash) ->
      if scope.markup
        price = inDollars(priceHash.price_cents) + (inDollars(priceHash.price_cents) * scope.markup)
        priceHash.currency + ' ' + $filter('number')(price, 2)
      else
        scope.formatPrice(priceHash)

    inDollars = (val) ->
      parseInt(val) / 100.0
)
