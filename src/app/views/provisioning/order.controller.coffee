@App.controller('ProvisioningOrderCtrl', ($scope, $q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig, ProvisioningHelper, MnoeProducts, toastr) ->

  vm = this
  vm.subscription = MnoeProvisioning.getCachedSubscription()
  vm.currencies = []
  vm.selectedCurrency = ""
  vm.filteredPricingPlans = []
  vm.pricedPlan = ProvisioningHelper.pricedPlan
  urlParams = {
    productId: $stateParams.productId,
    orgId: $stateParams.orgId,
    subscriptionId: $stateParams.subscriptionId,
    editAction: $stateParams.editAction,
    cart: $stateParams.cart
  }

  fetchSubscription = () ->
    orgPromise = MnoeOrganizations.get($stateParams.orgId)
    initPromise = MnoeProvisioning.initSubscription({productId: $stateParams.productId, subscriptionId: $stateParams.subscriptionId, orgId: $stateParams.orgId, cart: urlParams.cart})

    $q.all({organization: orgPromise, subscription: initPromise}).then((response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
      vm.subscription = response.subscription
      vm.subscription.organization_id = response.organization.data.id
    )

  vm.filterCurrencies = () ->
    vm.filteredPricingPlans = _.filter(vm.subscription.product.product_pricings,
      (pp) -> !vm.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == vm.selectedCurrency)
    )

  fetchProduct = () ->
    # When in edit mode, we will be getting the product ID from the subscription, otherwise from the url.
    vm.productId = vm.subscription.product?.id || $stateParams.productId
    MnoeProvisioning.getProduct(vm.productId, { editAction: $stateParams.editAction }).then(
      (response) ->
        vm.subscription.product = response

        # Get all the possible currencies
        currenciesArray = []
        _.forEach(vm.subscription.product.product_pricings,
          (pp) -> _.forEach(pp.prices, (p) -> currenciesArray.push(p.currency)))
        vm.currencies = _.uniq(currenciesArray)

        # Set a default currency
        if vm.currencies.includes(vm.orgCurrency)
          vm.selectedCurrency = vm.orgCurrency
        else
          vm.selectedCurrency = vm.currencies[0]

        # Filters the pricing plans not containing current currency
        vm.filterCurrencies()
        MnoeProvisioning.setSubscription(vm.subscription)
    )

  fetchCustomSchema = () ->
    MnoeProducts.fetchCustomSchema(vm.productId, { editAction: $stateParams.editAction }).then((response) ->
      # Some products have custom schemas, whereas others do not.
      vm.subscription.product.custom_schema = response
    )

  if _.isEmpty(vm.subscription)
    vm.isLoading = true
    fetchSubscription()
      .then(fetchProduct)
      .then(fetchCustomSchema)
      .then(() -> vm.next(vm.subscription) if vm.skipPriceSelection(vm.subscription.product))
      .catch((error) ->
        toastr.error('mnoe_admin_panel.dashboard.provisioning.subscriptions.product_error')
        $state.go('dashboard.customers.organization', {orgId: $stateParams.orgId})
        )
      .finally(() -> vm.isLoading = false)

  vm.subscriptionPlanText = switch $stateParams.editAction.toLowerCase()
    when 'new'
      'mnoe_admin_panel.dashboard.provisioning.order.new_title'
    when 'change'
      'mnoe_admin_panel.dashboard.provisioning.order.change_title'

  vm.next = (subscription, selectedCurrency) ->
    MnoeProvisioning.setSubscription(subscription)
    MnoeProvisioning.setSelectedCurrency(selectedCurrency)
    if vm.subscription.product.custom_schema?
      $state.go('dashboard.provisioning.additional_details', urlParams)
    else
      $state.go('dashboard.provisioning.confirm', urlParams)

  # Delete the cached subscription when we are leaving the subscription workflow.
  $scope.$on('$stateChangeStart', (event, toState) ->
    switch toState.name
      when "dashboard.provisioning.confirm", "dashboard.provisioning.order_summary", "dashboard.provisioning.additional_details"
        null
      else
        MnoeProvisioning.setSubscription({})
  )

  # Skip pricing selection for products with product_type 'application' if
  # single billing is disabled or if single billing is enabled but externally managed
  vm.skipPriceSelection = (product) ->
    product.product_type == 'application' && (!product.single_billing_enabled || !product.billed_locally)

  return
)
