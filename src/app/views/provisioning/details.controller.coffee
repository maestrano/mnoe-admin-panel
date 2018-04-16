@App.controller('ProvisioningDetailsCtrl', ($scope, $q, $state, $stateParams, MnoeProvisioning, MnoeOrganizations, schemaForm, PRICING_TYPES) ->
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
    id: $stateParams.id,
    nid: $stateParams.nid,
    editAction: $stateParams.editAction


  getCustomSchema = (product) ->
    # The schema is contained in field vm.product.custom_schema
    #
    # jsonref is used to resolve $ref references
    # jsonref is not cyclic at this stage hence the need to make a
    # reasonable number of passes (2 below + 1 in the sf-schema directive)
    # to resolve cyclic references
    schemaForm.jsonref(JSON.parse(product.custom_schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) ->
        vm.schema = schema
      )

  if _.isEmpty(vm.subscription)
    vm.isLoading = true
    # Fetch organizations, subscription, and products
    orgPromise = MnoeOrganizations.get($stateParams.orgId)
    prodsPromise = MnoeProvisioning.getProducts()
    initPromise = MnoeProvisioning.initSubscription({productNid: $stateParams.nid, subscriptionId: $stateParams.id, orgId: $stateParams.orgId })

    $q.all({organization: orgPromise, products: prodsPromise, subscription: initPromise}).then(
      (response) ->
        vm.orgCurrency = response.organization.data.billing_currency || MnoeAdminConfig.marketplaceCurrency()
        vm.subscription = response.subscription
        vm.subscription.organization_id = response.organization.data.id
        vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)


        # If the product id is available, get the product, otherwise find with the nid.
        productPromise = if vm.subscription.product?.id
          MnoeProvisioning.getProduct(vm.subscription.product.id, { editAction: $stateParams.editAction })
        else
          MnoeProvisioning.findProduct({nid: $stateParams.nid})

        productPromise.then(
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
