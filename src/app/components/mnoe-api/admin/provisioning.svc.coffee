# Service for managing the users.
@App.service 'MnoeProvisioning', ($q, $log, MnoeAdminApiSvc, MnoeOrganizations, MnoErrorsHandler) ->
  _self = @

  subscriptionsApi = (id) ->
    if id?
      MnoeAdminApiSvc.one('organizations', id).all('subscriptions')
    else
      MnoeAdminApiSvc.all('subscriptions')

  productsApi = MnoeAdminApiSvc.oneUrl('/products')
  productsPromise = null
  productsResponse = null

  subscription = {}

  defaultSubscription = {
    id: null
    product: null
    product_pricing: null
    organization: null
    custom_data: {}
  }

  # Return the list of product
  @getProducts = () ->
    return productsPromise if productsPromise?
    productsPromise = productsApi.get().then(
      (response) ->
        productsResponse = response.data.plain()
        response
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  # Find a product using its id or nid
  @findProduct = ({id = null, nid = null}) ->
    _self.getProducts().then(
      ->
        _.find(productsResponse.products, (a) -> a.id == id || a.nid == nid)
    )

  productPromises = {}
  @getProduct = (productId, params) ->
    productPromises["#{productId}/#{params.editAction}"] ?= MnoeAdminApiSvc.one('/products', productId).get(params)
      .then((response) -> response.data.product)

  @setSubscription = (s) ->
    subscription = s

  @getCachedSubscription = () ->
    subscription

  # Return the subscription
  # if productNid: return the default subscription
  # if subscriptionId: return the fetched subscription
  # else: return the subscription in cache (edition mode)
  @initSubscription = ({productId = null, subscriptionId = null, orgId = null, cart = null}) ->
    deferred = $q.defer()
    # Edit a subscription
    if !_.isEmpty(subscription)
      deferred.resolve(subscription)
    else if subscriptionId?
      _self.fetchSubscription(subscriptionId, orgId, cart).then(
        (response) ->
          angular.copy(response.data, subscription)
          deferred.resolve(subscription)
      )
    else if productId?
      # Create a new subscription to a product
      angular.copy(defaultSubscription, subscription)
      deferred.resolve(subscription)
    else
      deferred.resolve({})

    return deferred.promise

  createSubscription = (s) ->
    subscriptionsApi(s.organization_id).post({subscription: {product_id: s.product.id, product_pricing_id: s.product_pricing?.id, custom_data: s.custom_data, cart_entry: s.cart_entry}}).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
    )

  updateSubscription = (s) ->
    subscription.patch({subscription: {product_id: s.product.id, product_pricing_id: s.product_pricing?.id, custom_data: s.custom_data, edit_action: s.edit_action, cart_entry: s.cart_entry}}).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
    )

  # Detect if the subscription should be a POST or A PUT and call corresponding method
  @saveSubscription = (subscription) ->
    if subscription.id
      updateSubscription(subscription).then(
        (response) ->
          _self.setSubscription(response.data?.subscription)
          response.data?.subscription
      )
    else
      createSubscription(subscription).then(
        (response) ->
          _self.setSubscription(response.data)
          response.data
      )

  @fetchSubscription = (id, orgId, cart = false) ->
    params = if cart then { 'subscription[cart_entry]': 'true' } else {}
    MnoeAdminApiSvc.one('/organizations', orgId).one('subscriptions', id).get(params).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @getSubscriptions = (limit, offset, sort, orgId = null, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    subscriptionsApi(orgId).getList(params).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @getOrganizationsSubscriptionEvents = (limit, offset, sort, orgId = null, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    MnoeAdminApiSvc.one('organizations', orgId).all('subscription_events').getList(params).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
      )

  @getAllSubscriptionEvents = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    MnoeAdminApiSvc.all('subscription_events').getList(params).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @rejectSubscriptionEvent = (s) ->
    MnoeAdminApiSvc.one('subscription_events', s.id).post('/reject').catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @approveSubscriptionEvent = (s) ->
    MnoeAdminApiSvc.one('subscription_events', s.id).post('/approve').catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @getSubscriptionEvents = (subscriptionId, orgId, limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    MnoeAdminApiSvc.one('organizations', orgId).one('subscriptions', subscriptionId).all('subscription_events').getList(params).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @getSubscriptionEvent = (subscriptionId, orgId, id) ->
    MnoeAdminApiSvc.one('organizations', orgId).one('subscriptions', subscriptionId).customGET("/subscription_events/#{id}").catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  return
