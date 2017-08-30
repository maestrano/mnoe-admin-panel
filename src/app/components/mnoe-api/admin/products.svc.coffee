# Service for managing the users.
@App.service 'MnoeProducts', (MnoeAdminApiSvc, toastr) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all("products").getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        response
      (error) ->
        # Something went wrong
        toastr.error('mnoe_admin_panel.dashboard.product.retrieve.error')
    )

  @products = (limit, offset, sort, params = {}) ->
    return _getProducts(limit, offset, sort, params)

  # Fetch only the local products
  @localProducts = (limit, offset, sort, params = {}) ->
    params['where[local]'] = 'true'
    return _getProducts(limit, offset, sort, params)

  _getProducts = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    return MnoeAdminApiSvc.all("products").getList(params)

  @get = (id) ->
    MnoeAdminApiSvc.one('products', id).get()

  @create = (product) ->
    MnoeAdminApiSvc.all('/products').post(product)

  @update = (product) ->
    MnoeAdminApiSvc.one('/products', product.id).patch(product)

  @remove = (id) ->
    MnoeAdminApiSvc.one('products', id).remove().then(
      (response) ->
        response
        # product has been succesfuly removed
        toastr.success('mnoe_admin_panel.dashboard.product.delete.success')
      (error) ->
        # Something went wrong
        toastr.error('mnoe_admin_panel.dashboard.product.delete.error')
    )

  return @
