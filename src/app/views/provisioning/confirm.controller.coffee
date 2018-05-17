@App.controller('ProvisioningConfirmCtrl', ($scope, $q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig, ProvisioningHelper) ->
  vm = this

  vm.isLoading = true
  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  vm.subscription = MnoeProvisioning.getCachedSubscription()

  vm.editOrder = (reload = false) ->
    params = {
      productId: $stateParams.productId,
      orgId: $stateParams.orgId
      subscriptionId: $stateParams.subscriptionId,
      editAction: $stateParams.editAction,
      cart: $stateParams.cart
    }

    switch $stateParams.editAction.toLowerCase()
      when 'change', 'new', null
        $state.go('dashboard.provisioning.order', params, {reload: reload})
      else
        $state.go('dashboard.provisioning.additional_details', params, {reload: reload})

  # Happen when the user reload the browser during the provisioning
  if _.isEmpty(vm.subscription)
    # Redirect the user to the first provisioning screen
    vm.editOrder(true)
  else
    vm.singleBilling = vm.subscription.product.single_billing_enabled
    vm.billedLocally = vm.subscription.product.billed_locally
    vm.subscription.edit_action = $stateParams.editAction

  vm.orderTypeText = 'mnoe_admin_panel.dashboard.provisioning.subscriptions.' + $stateParams.editAction.toLowerCase()

  vm.orderEditable = () ->
    # The order is editable if we are changing the plan, or the product has a custom schema.
    switch $stateParams.editAction.toLowerCase()
      when 'change', 'new'
        true
      else
        if vm.subscription.product?.custom_schema then true else false

  $q.all({organization: orgPromise}).then(
    (response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
  ).finally(-> vm.isLoading = false)

  vm.validate = () ->
    vm.isLoading = true
    vm.subscription.cart_entry = true if $stateParams.cart
    vm.subscription.edit_action = $stateParams.editAction
    MnoeProvisioning.saveSubscription(vm.subscription).then(
      (subscription) ->
        if $stateParams.cart == 'true' && $stateParams.editAction == 'cancel'
          $state.go("dashboard.customers.organization", {orgId: $stateParams.orgId})
        else
          $state.go('dashboard.provisioning.order_summary', {orgId: $stateParams.orgId, subscriptionId: subscription.id, editAction: $stateParams.editAction})
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
