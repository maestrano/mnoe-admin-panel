@App.controller 'ProductController', ($stateParams, $state, $timeout, $document, Upload, MnoeProducts, toastr, MnoErrorsHandler, CURRENCIES) ->
  'ngInject'

  vm = this

  vm.product = {}
  vm.product.pricing_plans = []
  vm.currencies = _.clone(CURRENCIES.values)

  # Get the product
  MnoeProducts.get($stateParams.productId).then(
    (response) ->
      vm.product = response.data
      vm.product.values_display = []
      _.each(vm.product.values_attributes, (v) -> vm.product.values_display[v.name] = v.data)
  )

  #------------------------------------------------
  # Product management
  #------------------------------------------------

  vm.updateStatus = ->
    vm.product.patch(_.pick(vm.product, 'active')).then(
      (response) ->
        angular.copy(vm.product, response.data.plain().product)
        toastr.success('mnoe_admin_panel.dashboard.product.status.success', {extraData: {product: vm.product.name, status: vm.product.active.toString()}})
      (error) ->
        MnoErrorsHandler.processServerError(error)
        toastr.error('mnoe_admin_panel.dashboard.product.status.error', {extraData: {organization_name: vm.organization.name}})
    )

  vm.updateProduct = ->
    vm.product.values_attributes = _.map(_.keys(vm.product.values_display), (k) -> {name: k, data: vm.product.values_display[k]})
    vm.isLoading = true
    vm.product.patch(_.pick(vm.product, ['name', 'values_attributes'])).then(
      (response) ->
        toastr.success('mnoe_admin_panel.dashboard.product.success', {extraData: {product: vm.product.name}})
        angular.copy(vm.product, response.data.plain().product)
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.edit_product.error', {extraData: {organization_name: vm.organization.name}})
        MnoErrorsHandler.processServerError(error, vm.form)
    ).finally(-> vm.isLoading = false)

  #------------------------------------------------
  # Pricing plans management
  #------------------------------------------------

  # Add a new pricing plan to edit to the list
  vm.addPricingPlan = ->
    vm.pricingPlan = {
      name: '',
      description: '',
      free_trial_enabled: null,
      free_trial_duration: 0,
      per_duration: '',
      per_unit: '',
      prices: [{ currency: '', price_cents: '' }]
    }
    vm.currencies = _.clone(CURRENCIES.values)
    vm.product.product_pricings.push(vm.pricingPlan)

  vm.cancelPricingPlan = (pricingPlan) ->
    vm.currentPricingPlanId = null
    _.pull(vm.product.product_pricings, pricingPlan) unless pricingPlan.id?
    # Reset available currencies
    vm.currencies = _.clone(CURRENCIES.values)

  vm.deletePricingPlan = (pricingPlan) ->
    pricingIndex = vm.product.product_pricings.indexOf(pricingPlan)
    vm.product.product_pricings.splice(pricingIndex,1)
    vm.updateProduct()

  vm.editPricingPlan = (pricingPlan) ->
    # Check that a pricing plan is not already being edited
    return if !!vm.currentPricingPlanId
    # Set the pricing plan id to edit
    vm.currentPricingPlanId = pricingPlan.id
    # Remove already used currencies
    vm.currencies = _.difference(CURRENCIES.values, _.map(pricingPlan.prices, 'currency'))

  # Same id or no id (new record)
  vm.isCurrentPricingPlan = (pricingPlan) ->
    !pricingPlan.id || pricingPlan.id == vm.currentPricingPlanId

  #------------------------------------------------
  # Logo management
  #------------------------------------------------

  vm.uploadLogo = (file, form) ->
    file.upload = Upload.upload(
      headers: {'Accept': 'application/json'}
      url: "/mnoe/jpi/v1/admin/products/#{vm.product.id}/upload_logo"
      data:
        id: vm.product.id
        image: file
    )

    file.upload.then(
      (response) ->
        # Display upload successful & reset the form
        $timeout ->
          file.result = true
          form.$setPristine()

        # Remove the upload bar after 3000ms
        $timeout (->
          file.progress = -1
          return
        ), 3000
      (error) ->
        MnoErrorsHandler.processServerError(error)
        if error.status > 0
          file.error = true
      (evt) ->
        file.progress = parseInt(100.0 * evt.loaded / evt.total)
    )

  vm.deleteLogo = (asset) ->
    MnoeProducts.deleteAsset(asset)

  return
