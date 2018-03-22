@App.service 'PricingHelper', ($filter) ->
  _self = @

  @formatPrice = (price_in_cents, currency) ->
    if price_in_cents
      currency + ' ' + _self.inDollars(price_in_cents)
    else
      '-'

  @formatFinalPrice = (price_in_cents, currency, percentage) ->
    if percentage && price_in_cents
      price = _self.inDollars(price_in_cents) + (_self.inDollars(price_in_cents) * percentage)
      currency + ' ' + $filter('number')(price, 2)
    else
      _self.formatPrice(price_in_cents, currency)

  @inDollars = (val) ->
    parseInt(val) / 100.0

  return
