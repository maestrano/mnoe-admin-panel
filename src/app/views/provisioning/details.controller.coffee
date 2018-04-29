@App.controller('ProvisioningDetailsCtrl', ($scope, $q, $state, $stateParams, MnoeProvisioning, MnoeOrganizations, schemaForm, ProvisioningHelper, MnoeProducts, toastr) ->
  vm = this
<<<<<<< HEAD
=======

  vm.form = [ "*" ]
>>>>>>> [OPAL-432] Refactor frontend for change in mnoe #custom_schema endpoint
  vm.subscription = MnoeProvisioning.getCachedSubscription()
  vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)

  # We must use model schemaForm's sf-model, as #json_schema_opts are namespaced under model
  vm.model = vm.subscription.custom_data || {}

  # Methods under the vm.model are used for calculated fields under #json_schema_opts.
  # Used to calculate the end date for forms with a contractEndDate.
  vm.model.calculateEndDate = (startDate, contractLength) ->
    return null unless startDate && contractLength
    moment(startDate)
    .add(contractLength.split('Months')[0], 'M')
    .format('YYYY-MM-DD')

  urlParams =
    orgId: $stateParams.orgId,
    subscriptionId: $stateParams.subscriptionId,
    productId: $stateParams.productId,
    editAction: $stateParams.editAction

  # The schema is contained in field vm.product.custom_schema
  #
  # jsonref is used to resolve $ref references
  # jsonref is not cyclic at this stage hence the need to make a
  # reasonable number of passes (2 below + 1 in the sf-schema directive)
  # to resolve cyclic references
  setCustomSchema = (product) ->
    vm.model = vm.subscription.custom_data || {}
    return $state.go('dashboard.provisioning.confirm', urlParams, {reload: true}) unless product.custom_schema
    schemaForm.jsonref(JSON.parse(product.custom_schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) ->
        vm.schema = if schema.json_schema then schema.json_schema else schema
        vm.form = if schema.asf_options then schema.asf_options else ["*"]
        )

  fetchSubscription = () ->
    orgPromise = MnoeOrganizations.get(urlParams.orgId)
    initPromise = MnoeProvisioning.initSubscription({productId: urlParams.productId, subscriptionId: urlParams.subscriptionId, orgId: urlParams.orgId})
    $q.all({organization: orgPromise, subscription: initPromise}).then((response) ->
      vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
      vm.subscription = response.subscription
      vm.subscription.organization_id = response.organization.data.id
    )

  filterCurrencies = (productPricings) ->
    _.filter(productPricings,
      (pp) -> !ProvisioningHelper.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
    )

  fetchProduct = () ->
    # When in edit mode, we will be getting the product ID from the subscription, otherwise from the url.
    vm.productId = vm.subscription.product?.id || urlParams.productId

    MnoeProvisioning.getProduct(vm.productId, { editAction: urlParams.editAction }).then(
      (response) ->
        vm.subscription.product = response
        # Filters the pricing plans not containing current currency
        vm.subscription.product.product_pricings = filterCurrencies(vm.subscription.product.product_pricings)
        MnoeProvisioning.setSubscription(vm.subscription)
    )

  fetchCustomSchema = () ->
    MnoeProducts.fetchCustomSchema(vm.productId, { editAction: urlParams.editAction }).then((response) ->
      vm.subscription.product.custom_schema = response
      )

  if _.isEmpty(vm.subscription)
    $state.go('home.provisioning.order', urlParams, {reload: true}) if urlParams.editAction == 'NEW'
    vm.isLoading = true
    fetchSubscription().then(fetchProduct).then(fetchCustomSchema)
      .then(() -> setCustomSchema(vm.subscription.product))
      .catch((error) ->
        toastr.error('mnoe_admin_panel.dashboard.provisioning.subscriptions.product_error')
        $state.go('dashboard.customers.organization', {orgId: urlParams.orgId})
        )
      .finally(() -> vm.isLoading = false)
  # Ensure that the subscription has a product_pricing and custom schema, otherwise redirect to order page.
  else if vm.subscription.product?.custom_schema && vm.subscription.product_pricing
    setCustomSchema(vm.subscription.product)
  else
    $state.go('dashboard.provisioning.order', urlParams, {reload: true})

  vm.submit = (form) ->
    $scope.$broadcast('schemaFormValidate')
    return unless form.$valid
    vm.subscription.custom_data = vm.model
    MnoeProvisioning.setSubscription(vm.subscription)
    $state.go('dashboard.provisioning.confirm', urlParams)

  vm.editPlanText = 'mnoe_admin_panel.dashboard.provisioning.details.' + urlParams.editAction.toLowerCase() + '_title'

  # Delete the cached subscription when we are leaving the subscription workflow.
  $scope.$on('$stateChangeStart', (event, toState) ->
    switch toState.name
      when "dashboard.provisioning.order", "dashboard.provisioning.order_summary", "dashboard.provisioning.confirm"
        null
      else
        MnoeProvisioning.setSubscription({})
  )

  return
)
