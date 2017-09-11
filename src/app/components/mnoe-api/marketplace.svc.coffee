# Service for the listing of Apps on the Markeplace
# MnoeMarketplace.getList()

# .getApps()
# => GET /mnoe/jpi/v1/marketplace
# Return the list off apps and categories
#   {categories: [], apps: []}
@App.service 'MnoeMarketplace', (MnoeApiSvc, MnoeObservables, OBS_KEYS) ->
  _self = @

  # Using this syntax will not trigger the data extraction in MnoeApiSvc
  # as the /marketplace payload isn't encapsulated in "{ marketplace: categories {...}, apps {...} }"
  marketplaceApi = MnoeApiSvc.oneUrl('/marketplace')

  marketplacePromise = null

  refreshApps = ->
    marketplacePromise = null
    _self.getApps()

  @getApps = () ->
    return marketplacePromise if marketplacePromise?
    marketplacePromise = marketplaceApi.get()

  MnoeObservables.registerCb(OBS_KEYS.marketplaceChanged, refreshApps)

  return @
