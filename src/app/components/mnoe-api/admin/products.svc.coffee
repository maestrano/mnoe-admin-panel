# Service for managing the users.
@App.service 'MnoeProducts', ($q, toastr, MnoeAdminApiSvc, MnoErrorsHandler) ->

  # Transforms the values_attributes ([name: 'Some string', data: 'Its value'])
  # to attributes (vm.product.some_string).
  # Note: duplicate code to MnoeMarketplace in mno-enterprise-angular.
  _transform_products = (products) ->
    _.map(products, (product) ->
      _.each(product.values_attributes, (v) ->
        try
          product[_.snakeCase(v.name)] = JSON.parse(v.data)
        catch
          product[_.snakeCase(v.name)] = v.data
      )
      product.screenshots = _.map(product.assets_attributes, (a) -> a.url)
      product
    )

  @list = (limit, offset, sort) ->
    return _getProducts(limit, offset, sort)

  @products = (limit, offset, sort, params = {}) ->
    return _getProducts(limit, offset, sort, params)

  # Fetch only the local products
  @localProducts = (limit, offset, sort, params = {}) ->
    params['where[local]'] = 'true'
    return _getProducts(limit, offset, sort, params)

  # Fetch only the single billing enabled products
  @singleBillingEnabledProducts = (limit, offset, sort, params = {}) ->
    params['where[single_billing_enabled]'] = 'true'
    return _getProducts(limit, offset, sort, params)

  _getProducts = (limit, offset, sort, params = {}) ->
    params['order_by'] = sort
    params['limit'] = limit
    params['offset'] = offset
    return MnoeAdminApiSvc.all('products').getList(params)
      .then(
        (response) ->
          response.data = _transform_products(response.data)
          response
        )
      .catch(
        (error) ->
          toastr.error('mnoe_admin_panel.dashboard.product.retrieve.error')
          MnoErrorsHandler.processServerError(error)
          $q.reject(error)
        )

  @fetchCustomSchema = (id, params) ->
    MnoeAdminApiSvc.one("/products/#{id}/custom_schema").get(params)
      .then((response) ->
        response.data.custom_schema
        )

  @get = (id) ->
    MnoeAdminApiSvc.one('products', id).get()
      .then(
        (response) ->
          response.data = _transform_products([response.data])[0] if response?.data?
          response
      )
      .catch(
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
