@App.controller('ProvisioningConfirmCtrl', ($scope, $q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAdminConfig, ProvisioningHelper, schemaForm) ->
  vm = this

  vm.isLoading = true
  orgPromise = MnoeOrganizations.get($stateParams.orgId)
  vm.subscription = MnoeProvisioning.getCachedSubscription()
  vm.selectedCurrency = MnoeProvisioning.getSelectedCurrency()
  vm.cartItem = $stateParams.cart == 'true'
  vm.quoteFetched = true
  vm.quoteBased = false

  vm.editOrder = (reload = false) ->
    params = {
      productId: $stateParams.productId,
      orgId: $stateParams.orgId
      subscriptionId: $stateParams.subscriptionId,
      editAction: $stateParams.editAction,
      cart: $stateParams.cart
    }

    switch $stateParams.editAction.toLowerCase()
      when 'change', 'provision', null
        $state.go('dashboard.provisioning.order', params, {reload: reload})
      else
        $state.go('dashboard.provisioning.additional_details', params, {reload: reload})

  setCustomSchema = () ->
    parsedSchema = JSON.parse(vm.subscription.product.custom_schema)
    schema = parsedSchema.json_schema || parsedSchema
    vm.form = parsedSchema.asf_options || ["*"]
    schemaForm.jsonref(schema)
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) ->
        vm.schema = schema
      )

  if vm.subscription.product_pricing?.quote_based
    vm.quoteBased = true
    vm.quoteFetched = false
    MnoeProvisioning.getQuote(vm.subscription, vm.selectedCurrency).then(
      (response) ->
        vm.quotedPrice = response.data.totalContractValue?.quote
        vm.quotedCurrency = response.data.totalContractValue?.currency
        # To be passed to the order summary screen.
        MnoeProvisioning.setQuote(response.data.totalContractValue)
        vm.quoteFetched = true
      (error) ->
        vm.quoteFetched = true
        $log.error('Error while fetching quote', error)
    )

  # Happen when the user reload the browser during the provisioning
  if _.isEmpty(vm.subscription)
    # Redirect the user to the first provisioning screen
    vm.editOrder(true)
  else
    vm.singleBilling = vm.subscription.product.single_billing_enabled
    vm.billedLocally = vm.subscription.product.billed_locally
    # Render custom Schema if it exists
    setCustomSchema() if vm.subscription.custom_data && vm.subscription.product.custom_schema

  vm.orderTypeText = 'mnoe_admin_panel.dashboard.provisioning.subscriptions.' + $stateParams.editAction.toLowerCase()

  vm.orderEditable = () ->
    # The order is editable if we are changing the plan, or the product has a custom schema.
    return true if vm.subscription.product?.custom_schema
    # Disable editing if unable to initially select a pricing plan.
    return false if ProvisioningHelper.skipPriceSelection(vm.subscription.product)
    switch $stateParams.editAction.toLowerCase()
      when 'change', 'provision'
        true
      else
        false

  $q.all({organization: orgPromise}).then(
    (response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
  ).finally(-> vm.isLoading = false)

  vm.validate = () ->
    vm.isLoading = true
    vm.subscription.cart_entry = true if vm.cartItem
    vm.subscription.event_type = $stateParams.editAction
    MnoeProvisioning.saveSubscription(vm.subscription, vm.selectedCurrency, $stateParams.orgId).then(
      (subscription) ->
        if vm.cartItem
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

  # Delete the cached subscription when we are leaving the subscription workflow.
  $scope.$on('$stateChangeStart', (event, toState) ->
    switch toState.name
      when "dashboard.provisioning.order", "dashboard.provisioning.order_summary", "dashboard.provisioning.additional_details"
        null
      else
        MnoeProvisioning.setSubscription({})
  )

  vm.pricingText = () ->
    if !vm.singleBilling
      'mnoe_admin_panel.dashboard.provisioning.confirm.pricing_info.single_billing_disabled'
    else if vm.billedLocally
      'mnoe_admin_panel.dashboard.provisioning.confirm.pricing_info.billed_locally'
    else
      'mnoe_admin_panel.dashboard.provisioning.confirm.pricing_info.externally_managed'

  return
)
