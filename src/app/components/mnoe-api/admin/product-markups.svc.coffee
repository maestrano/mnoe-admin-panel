# Service for managing the users.
@App.service 'MnoeProductMarkups', ($q, $log, MnoeAdminApiSvc, MnoeObservables, OBS_KEYS) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all('product_markups').getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.markupChanged, response)
        response
    )

  @markups = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    return MnoeAdminApiSvc.all("product_markups").getList(params)

  @search = (terms) ->
    MnoeAdminApiSvc.all('product_markups').getList({terms: terms})

  @get = (id) ->
    MnoeAdminApiSvc.one('product_markups', id).get()

  @search = (terms) ->
    MnoeAdminApiSvc.all("product_markups").getList({terms: terms})

  # Create a product markup if not already existing
  # POST /mnoe/jpi/v1/admin/product_markups
  @addProductMarkup = (markup) ->
    promise = MnoeAdminApiSvc.all('product_markups').post({product_markup: markup}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.markupAdded, promise)
        response
    )

  @updateProductMarkup = (markup) ->
    promise = MnoeAdminApiSvc.one('product_markups', markup.id).patch({product_markup: markup}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.markupChanged, promise)
        response
    )

  @deleteProductMarkup = (markup) ->
    promise = MnoeAdminApiSvc.one('product_markups', markup.id).remove().then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.markupChanged, promise)
        response
    )

  return @
