@App.service 'ProvisioningHelper', (PRICING_TYPES) ->
  _self = @

  @pricedPlan = (plan) ->
    plan?.pricing_type not in PRICING_TYPES['unpriced']

  # Skip pricing selection for products with product_type 'application' if
  # single billing is disabled or if single billing is enabled but externally managed
  @skipPriceSelection = (product) ->
    product.product_type == 'application' && (!product.single_billing_enabled || !product.billed_locally)

  return @
