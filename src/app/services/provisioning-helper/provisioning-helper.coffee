@App.service 'ProvisioningHelper', (PRICING_TYPES) ->
  _self = @

  @pricedPlan = (plan) ->
    plan.pricing_type not in PRICING_TYPES['unpriced']

  return @
