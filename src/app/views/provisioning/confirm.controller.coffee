@App.controller('ProvisioningConfirmCtrl', ($q, $scope, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig, ProvisioningHelper) ->
  vm = this

  vm.isLoading = true
  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  vm.subscription = MnoeProvisioning.getSubscription()
  vm.singleBilling = vm.subscription.product.single_billing_enabled
  vm.billedLocally = vm.subscription.product.billed_locally

  # Happen when the user reload the browser during the provisioning
  if _.isEmpty(vm.subscription)
    # Redirect the user to the first provisioning screen
    $state.go('dashboard.provisioning.order', {orgId: $stateParams.orgId, id: $stateParams.id, nid: $stateParams.nid, cart: $stateParams.cart}, {reload: true})

  $q.all({organization: orgPromise}).then(
    (response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
  ).finally(-> vm.isLoading = false)

  vm.validate = () ->
    vm.isLoading = true
    vm.subscription.cart_entry = true if $stateParams.cart
    MnoeProvisioning.saveSubscription(vm.subscription).then(
      (subscription) ->
        $state.go('dashboard.provisioning.order_summary', {orgId: $stateParams.orgId, subscriptionId: subscription.id, cart: $stateParams.cart})
    ).finally(-> vm.isLoading = false)

  vm.addToCart = ->
    vm.isLoading = true
    vm.subscription.cart_entry = true
    MnoeProvisioning.saveSubscription(vm.subscription).then(
      (response) ->
        $state.go('dashboard.customers.organization', {orgId: $stateParams.orgId})
    ).finally(-> vm.isLoading = false)

  # Return true if the plan has a dollar value
  vm.pricedPlan = ProvisioningHelper.pricedPlan

  vm.editOrder = () ->
    $state.go('dashboard.provisioning.order', {nid: $stateParams.nid, orgId: $stateParams.orgId, id: $stateParams.id, cart: $stateParams.cart})

  # Delete the cached subscription when we are leaving the subscription workflow.
  $scope.$on('$stateChangeStart', (event, toState) ->
    switch toState.name
      when "dashboard.provisioning.order", "dashboard.provisioning.order_summary", "dashboard.provisioning.additional_details"
        null
      else
        MnoeProvisioning.setSubscription({})
  )

  return
)
