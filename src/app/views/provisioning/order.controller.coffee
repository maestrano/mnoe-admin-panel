@App.controller('ProvisioningOrderCtrl', ($q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig) ->
  vm = this

  vm.isLoading = true
  vm.orgCurrency = MnoeAdminConfig.marketplaceCurrency()
  vm.product = null

  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  prodsPromise = MnoeProvisioning.getProducts()
  initPromise = MnoeProvisioning.initSubscription({productNid: $stateParams.nid, subscriptionId: $stateParams.id, orgId: $stateParams.orgId})

  $q.all({organization: orgPromise, products: prodsPromise, subscription: initPromise}).then(
    (response) ->
      vm.subscription = response.subscription
      console.log("### DEBUG response.organization", response.organization.data.plain())
      vm.subscription.organization_id = response.organization.data.id

      MnoeProvisioning.findProduct({id: vm.subscription.product?.id, nid: $stateParams.nid}).then(
        (response) ->
          vm.subscription.product = response

          # Filters the pricing plans not containing current currency
          vm.subscription.product.product_pricings = _.filter(vm.subscription.product.product_pricings,
            (pp) -> _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
          )

          MnoeProvisioning.setSubscription(vm.subscription)
      )
  ).finally(-> vm.isLoading = false)

  vm.next = (subscription) ->
    MnoeProvisioning.setSubscription(subscription)
    if vm.subscription.product.custom_schema?
      $state.go('dashboard.provisioning.additional_details')
    else
      $state.go('dashboard.provisioning.confirm')

  return
)
