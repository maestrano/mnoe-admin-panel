@App.controller('ProvisioningOrderCtrl', ($scope, $q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig, ProvisioningHelper) ->
  vm = this

  vm.isLoading = true
  vm.product = null

  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  prodsPromise = MnoeProvisioning.getProducts()
  initPromise = MnoeProvisioning.initSubscription({productNid: $stateParams.nid, subscriptionId: $stateParams.id, orgId: $stateParams.orgId})

  vm.pricedPlan = ProvisioningHelper.pricedPlan

  $q.all({organization: orgPromise, products: prodsPromise, subscription: initPromise}).then(
    (response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
      vm.subscription = response.subscription
      vm.subscription.organization_id = response.organization.data.id

      # If the product id is available, get the product, otherwise find with the nid.
      productPromise = if vm.subscription.product?.id
        MnoeProvisioning.getProduct(vm.subscription.product.id, { editAction: $stateParams.editAction })
      else
        MnoeProvisioning.findProduct({nid: $stateParams.nid})

      productPromise.then(
        (response) ->
          vm.subscription.product = response

          vm.next(vm.subscription) if vm.skipPriceSelection(vm.subscription.product)

          # Filters the pricing plans not containing current currency
          vm.subscription.product.product_pricings = _.filter(vm.subscription.product.product_pricings,
            (pp) -> !vm.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
          )

          MnoeProvisioning.setSubscription(vm.subscription)
      )
  ).finally(-> vm.isLoading = false)

  vm.next = (subscription) ->
    MnoeProvisioning.setSubscription(subscription)
    params = {
      orgId: $stateParams.orgId,
      id: $stateParams.id,
      nid: $stateParams.nid,
      editAction: $stateParams.editAction
    }
    if vm.subscription.product.custom_schema?
      $state.go('dashboard.provisioning.additional_details', params)
    else
      $state.go('dashboard.provisioning.confirm', params)

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
