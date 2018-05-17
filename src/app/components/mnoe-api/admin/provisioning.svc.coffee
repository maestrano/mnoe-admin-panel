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
  selectedCurrency = ""

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

  @setSubscription = (s) ->
    subscription = s

  @getSubscription = () ->
    subscription

  @setSelectedCurrency = (c) ->
    selectedCurrency = c

  @getSelectedCurrency = () ->
    selectedCurrency

  # Return the subscription
  # if productNid: return the default subscription
  # if subscriptionId: return the fetched subscription
  # else: return the subscription in cache (edition mode)
  @initSubscription = ({productNid = null, subscriptionId = null, orgId = null}) ->
    deferred = $q.defer()

    # Edit a subscription
    if !_.isEmpty(subscription)
      deferred.resolve(subscription)
    else if subscriptionId?
      _self.fetchSubscription(subscriptionId, orgId).then(
        (response) ->
          angular.copy(response.data, subscription)
          deferred.resolve(subscription)
      )
    else if productNid?
      # Create a new subscription to a product
      angular.copy(defaultSubscription, subscription)
      deferred.resolve(subscription)
    else
      deferred.resolve({})

    return deferred.promise

  createSubscription = (s, c) ->
    subscriptionsApi(s.organization_id).post({subscription: {currency: c,product_id: s.product.id, product_pricing_id: s.product_pricing?.id, custom_data: s.custom_data}}).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
    )

  updateSubscription = (s, c) ->
    subscription.patch({subscription: {currency: c,product_id: s.product.id, product_pricing_id: s.product_pricing?.id, custom_data: s.custom_data}}).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
    )

  # Detect if the subscription should be a POST or A PUT and call corresponding method
  @saveSubscription = (subscription, currency) ->
    if subscription.id
      updateSubscription(subscription, currency).then(
        (response) ->
          _self.setSubscription(response.data.subscription)
          response.data.subscription
      )
    else
      createSubscription(subscription, currency).then(
        (response) ->
          _self.setSubscription(response.data)
          response.data
      )

  @fetchSubscription = (id, orgId) ->
    MnoeAdminApiSvc.one('/organizations', orgId).one('subscriptions', id).get().catch(
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

  @cancelSubscription = (s) ->
    MnoeAdminApiSvc.one('organizations', s.organization_id).one('subscriptions', s.id).post('/cancel').catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @approveSubscription = (s) ->
    MnoeAdminApiSvc.one('organizations', s.organization_id).one('subscriptions', s.id).post('/approve').catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @fulfillSubscription = (s) ->
    MnoeAdminApiSvc.one('organizations', s.organization_id).one('subscriptions', s.id).post('/fulfill').catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @getSubscriptionEvents = (subscriptionId, orgId) ->
    MnoeAdminApiSvc.one('organizations', orgId).one('subscriptions', subscriptionId).customGET('/subscription_events').catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  return
