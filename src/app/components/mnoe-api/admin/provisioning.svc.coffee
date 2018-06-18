# Service for managing the users.
@App.service 'MnoeProvisioning', ($q, $log, MnoeAdminApiSvc, MnoeOrganizations, MnoErrorsHandler, MnoeObservables, OBS_KEYS) ->
  _self = @

  subscriptionsApi = (id) ->
    if id?
      MnoeAdminApiSvc.one('organizations', id).all('subscriptions')
    else
      MnoeAdminApiSvc.all('subscriptions')

  productsApi = MnoeAdminApiSvc.oneUrl('/products')
  productsPromise = null
  productsResponse = null
  quote = {}
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

  productPromises = {}
  @getProduct = (productId, params) ->
    productPromises["#{productId}/#{params.editAction}"] ?= MnoeAdminApiSvc.one('/products', productId).get(params)
      .then((response) -> response.data.product)

  @setSubscription = (s) ->
    subscription = s

  @getCachedSubscription = () ->
    subscription

  @setSelectedCurrency = (c) ->
    selectedCurrency = c

  @getSelectedCurrency = () ->
    selectedCurrency

  @setQuote = (q) ->
    quote = q

  @getCachedQuote = () ->
    { price: quote?.quote, currency: quote?.currency }

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

  subscriptionParams = (s, c) ->
    {
      subscription: {
        product_id: s.product.id,
        cart_entry: s.cart_entry,
        subscription_events_attributes: [subscriptionEventParams(s, c)]
      }
    }

  subscriptionEventParams = (s, c) ->
    {
      event_type: s.event_type,
      product_pricing_id: s.product_pricing?.id,
      subscription_details: {
        start_date: s.start_date,
        custom_data: s.custom_data,
        currency: c,
        max_licenses: s.max_licenses
      }
    }

  createSubscription = (s, c) ->
    subscriptionsApi(s.organization_id).post(subscriptionParams(s,c)).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
    )

  updateSubscription = (s, c) ->
    subscription.patch({subscription:
      {currency: c, product_id: s.product.id, product_pricing_id: s.product_pricing?.id, max_licenses: s.max_licenses, custom_data: s.custom_data, edit_action: s.edit_action, cart_entry: s.cart_entry
      }}).catch(
        (error) ->
          MnoErrorsHandler.processServerError(error)

  createSubscriptionEvent = (s, c, orgId) ->
    MnoeAdminApiSvc.one('organizations', orgId).one('subscriptions', s.id).all('subscription_events')
      .post({subscription_event: subscriptionEventParams(s,c)}).catch((error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  # Detect if the subscription should be a POST or A PUT and call corresponding method
  @saveSubscription = (subscription, currency, orgId) ->
    # If subscription already exists, create a subscription event for the subscription.
    if subscription.id
      createSubscriptionEvent(subscription, currency, orgId).catch(
        (error) ->
          MnoErrorsHandler.processServerError(error)
      )
    # Otherwise create the subscription.
    else
      createSubscription(subscription, currency).then(
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
    MnoeAdminApiSvc.one('subscription_events', s.id).post('/reject').then(
      (success) ->
        MnoeObservables.notifyObservers(OBS_KEYS.subscriptionEventChanged, s.id)
    ).catch(
      (error) ->
        MnoErrorsHandler.processServerError(error)
        $q.reject(error)
    )

  @getQuote = (s, currency) ->
    quoteParams = {product_id: s.product.id, product_pricing_id: s.product_pricing?.id, custom_data: s.custom_data, organization_id: s.organization_id, selected_currency: currency}
    MnoeAdminApiSvc.one('organizations', s.organization_id).all('quotes').post(quote: quoteParams)

  @approveSubscriptionEvent = (s) ->
    MnoeAdminApiSvc.one('subscription_events', s.id).post('/approve').then(
      (success) ->
        MnoeObservables.notifyObservers(OBS_KEYS.subscriptionEventChanged, s.id)
    ).catch(
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
