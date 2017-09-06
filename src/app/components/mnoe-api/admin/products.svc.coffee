# Service for managing the users.
@App.service 'MnoeProducts', ($q, toastr, MnoeAdminApiSvc, MnoErrorsHandler) ->

  @list = (limit, offset, sort) ->
    MnoeAdminApiSvc.all('products').getList({order_by: sort, limit: limit, offset: offset}).catch(
      (error) ->
        # Something went wrong
        toastr.error('mnoe_admin_panel.dashboard.product.retrieve.error')
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @products = (limit, offset, sort, params = {}) ->
    return _getProducts(limit, offset, sort, params)

  # Fetch only the local products
  @localProducts = (limit, offset, sort, params = {}) ->
    params['where[local]'] = 'true'
    return _getProducts(limit, offset, sort, params)

  _getProducts = (limit, offset, sort, params = {}) ->
    params['order_by'] = sort
    params['limit'] = limit
    params['offset'] = offset
    return MnoeAdminApiSvc.all('products').getList(params).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @get = (id) ->
    MnoeAdminApiSvc.one('products', id).get().catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @create = (product) ->
    MnoeAdminApiSvc.all('/products').post(product).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @update = (product) ->
    MnoeAdminApiSvc.one('/products', product.id).patch(product).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @remove = (id) ->
    MnoeAdminApiSvc.one('products', id).remove().then(
      (response) ->
        response
        # product has been succesfuly removed
        toastr.success('mnoe_admin_panel.dashboard.product.delete.success')
      (error) ->
        # Something went wrong
        MnoErrorsHandler.processServerError(error)
        toastr.error('mnoe_admin_panel.dashboard.product.delete.error')
        $q.reject(error)
    )

  @deleteAsset = (asset) ->
    MnoeAdminApiSvc.one('assets', asset.id).remove().catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  return @
