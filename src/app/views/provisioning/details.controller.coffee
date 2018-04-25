@App.controller('ProvisioningDetailsCtrl', ($scope, $q, $state, $stateParams, MnoeProvisioning, MnoeOrganizations, schemaForm, PRICING_TYPES, toastr) ->
  vm = this
  vm.subscription = MnoeProvisioning.getSubscription()

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
  getCustomSchema = (product) ->
    customSchema = JSON.parse(product.custom_schema)
    if customSchema.status == 'error'
      toastr.error('mnoe_admin_panel.dashboard.provisioning.subscriptions.custom_schema_error')
      $state.go('dashboard.customers.organization', {orgId: $stateParams.orgId})
    else
      schemaForm.jsonref(customSchema)
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) ->
          vm.schema = if schema.json_schema then schema.json_schema else schema
          vm.form = if schema.asf_options then schema.asf_options else ["*"]
          )

  if _.isEmpty(vm.subscription)
    vm.isLoading = true
    # Fetch organizations, subscription, and products
    orgPromise = MnoeOrganizations.get($stateParams.orgId)
    initPromise = MnoeProvisioning.initSubscription({productId: $stateParams.productId, subscriptionId: $stateParams.subscriptionId, orgId: $stateParams.orgId})

    $q.all({organization: orgPromise, subscription: initPromise}).then(
      (response) ->
        vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
        vm.subscription = response.subscription
        vm.subscription.organization_id = response.organization.data.id
        vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)

        # When in edit mode, we will be getting the product ID from the subscription, otherwise from the url.
        productId = vm.subscription.product?.id || $stateParams.productId
        MnoeProvisioning.getProduct(productId, { editAction: $stateParams.editAction }).then(
          (response) ->
            vm.subscription.product = response

            # Filters the pricing plans not containing current currency
            vm.subscription.product.product_pricings = _.filter(vm.subscription.product.product_pricings,
              (pp) -> (pp.pricing_type in PRICING_TYPES['unpriced']) || _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
            )

            MnoeProvisioning.setSubscription(vm.subscription)

            vm.subscription.product
          ).then((product) -> getCustomSchema(product))
        ).finally(-> vm.isLoading = false)
  else if vm.subscription?.product
    getCustomSchema(vm.subscription.product)
  else
    $state.go('dashboard.provisioning.order', urlParams)


  vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)

  vm.submit = (form) ->
    $scope.$broadcast('schemaFormValidate')
    return unless form.$valid
    vm.subscription.custom_data = vm.model
    MnoeProvisioning.setSubscription(vm.subscription)
    $state.go('dashboard.provisioning.confirm', urlParams)

  # Delete the cached subscription when we are leaving the subscription workflow.
  $scope.$on('$stateChangeStart', (event, toState) ->
    switch toState.name
      when "dashboard.provisioning.order", "dashboard.provisioning.order_summary", "dashboard.provisioning.confirm"
        null
      else
        MnoeProvisioning.setSubscription({})
  )

  vm.editPlanText = () ->
    'mnoe_admin_panel.dashboard.provisioning.details.' + $stateParams.editAction.toLowerCase() + '_title'

  return
)
