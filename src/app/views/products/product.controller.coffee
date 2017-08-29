@App.controller 'ProductController', ($stateParams, $state, $timeout, $document, Upload, MnoeProducts, toastr, MnoErrorsHandler, CURRENCIES) ->
  'ngInject'
  
  vm = this

  vm.product = {}
  vm.product.pricing_plans = []
  vm.productId = $stateParams.productId
  vm.currencies = _.clone(CURRENCIES.values)

  # Get the product
  MnoeProducts.get(vm.productId).then(
    (response) ->
      vm.product = response.data.plain()
  )
  
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

  vm.updateStatus = () ->
    vm.product.active = !vm.product.active
    vm.updateProduct()

  vm.deleteLogo = () ->
    vm.product.logo = null

  vm.uploadLogo = (file, form) ->
    file.upload = Upload.upload(
      headers: {'Accept': 'application/json'}
      url: "/mnoe/jpi/v1/admin/products/#{vm.productId}/upload_logo"
      data:
        id: vm.productId
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

  vm.updateProduct = () ->
    vm.isLoading = true
    MnoeProducts.update(vm.product).then(
      (response) ->
        toastr.success('mnoe_admin_panel.dashboard.product.success', {extraData: {product: vm.product.name}})
        response = response.data.plain()
        vm.product = response.product
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.edit_product.error', {extraData: {organization_name: vm.organization.name}})
        MnoErrorsHandler.processServerError(error, vm.form)
    ).finally(-> vm.isLoading = false)

  return vm
