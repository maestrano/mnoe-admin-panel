@App.controller('ProvisioningOrderCtrl', ($scope, $q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig, ProvisioningHelper) ->
  vm = this

  vm.isLoading = true
  vm.product = null
  vm.selectedCurrency = ''
  vm.currencies = []
  vm.filteredPricingPlans = []

  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  prodsPromise = MnoeProvisioning.getProducts()
  initPromise = MnoeProvisioning.initSubscription({productNid: $stateParams.nid, subscriptionId: $stateParams.id, orgId: $stateParams.orgId})

  # Return true if the plan has a dollar value
  vm.pricedPlan = ProvisioningHelper.pricedPlan

  $q.all({organization: orgPromise, products: prodsPromise, subscription: initPromise}).then(
    (response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
      vm.subscription = response.subscription
      vm.subscription.organization_id = response.organization.data.id

      MnoeProvisioning.findProduct({id: vm.subscription.product?.id, nid: $stateParams.nid}).then(
        (response) ->
          vm.subscription.product = response

          vm.next(vm.subscription) if vm.skipPriceSelection(vm.subscription.product)

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
          vm.pricingPlanFilter()

          MnoeProvisioning.setSubscription(vm.subscription)
      )
  ).finally(-> vm.isLoading = false)

  # Filters the pricing plans not containing current currency
  vm.pricingPlanFilter = () ->
    vm.filteredPricingPlans = _.filter(vm.subscription.product.product_pricings,
      (pp) -> !vm.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == vm.selectedCurrency)
    )

  # Filters the pricing plans not containing current currency
  vm.pricingPlanFilter = () ->
    vm.filteredPricingPlans = _.filter(vm.subscription.product.product_pricings,
      (pp) -> !vm.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == vm.selectedCurrency)
    )

  vm.next = (subscription, selectedCurrency) ->
    MnoeProvisioning.setSubscription(subscription)
    MnoeProvisioning.setSelectedCurrency(selectedCurrency)
    if vm.subscription.product.custom_schema?
      $state.go('dashboard.provisioning.additional_details', {orgId: $stateParams.orgId, id: $stateParams.id, nid: $stateParams.nid})
    else
      $state.go('dashboard.provisioning.confirm', {orgId: $stateParams.orgId, id: $stateParams.id, nid: $stateParams.nid})

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
