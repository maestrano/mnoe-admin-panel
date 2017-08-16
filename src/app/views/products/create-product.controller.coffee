@App.controller 'CreateProductController', (MnoeProducts, toastr, $state) ->
  'ngInject'
  
  vm = this
  vm.product = {}
  vm.pricing = {}
  vm.prices = {}

  vm.submitProduct = () ->
    vm.isLoading = true
    if vm.product.status == 'mnoe_admin_panel.dashboard.new_product.published'
      vm.product.active = true

    # format prices
    vm.pricing.prices = [
      { 'currency': 'USD', 'price_cents': vm.prices.USD },
      { 'currency': 'EUR', 'price_cents': vm.prices.EUR },
      { 'currency': 'AUD', 'price_cents': vm.prices.AUD }
    ]
    # merge product pricing
    vm.product.product_pricings = [vm.pricing]

    MnoeProducts.create(vm.product).then(
      (response) ->
        toastr.success('mnoe_admin_panel.dashboard.new_product.success', {extraData: {product: vm.product.name}})
        response = response.data.plain()
        # Go to products screen
        $state.go('dashboard.product',({productId: response.product.id}))
      (error) ->
        $document.scrollTopAnimated(0)
        toastr.error('mnoe_admin_panel.dashboard.new_product.error', {extraData: {organization_name: vm.organization.name}})
        MnoErrorsHandler.processServerError(error, vm.form)
    ).finally(-> vm.isLoading = false)

  return vm
