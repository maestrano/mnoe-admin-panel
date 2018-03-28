@App.controller('ProvisioningConfirmCtrl', ($q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig, PRICING_TYPES) ->
  vm = this

  vm.isLoading = true
  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  vm.subscription = MnoeProvisioning.getSubscription()

  # Happen when the user reload the browser during the provisioning
  if _.isEmpty(vm.subscription)
    # Redirect the user to the first provisioning screen
    $state.go('dashboard.provisioning.order', {orgId: $stateParams.orgId, id: $stateParams.id, nid: $stateParams.nid}, {reload: true})

  $q.all({organization: orgPromise}).then(
    (response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
  ).finally(-> vm.isLoading = false)

  vm.validate = () ->
    vm.isLoading = true
    MnoeProvisioning.saveSubscription(vm.subscription).then(
      (subscription) ->
        $state.go('dashboard.provisioning.order_summary', {orgId: $stateParams.orgId, subscriptionId: subscription.id})
    ).finally(-> vm.isLoading = false)

  vm.pricingUnavailable = _.includes(PRICING_TYPES['unpriced'], vm.subscription.product_pricing.pricing_type)

  return
)
