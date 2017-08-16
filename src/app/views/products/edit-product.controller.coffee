@App.controller 'EditProductController', ($stateParams, $state, MnoeProducts, toastr, MnoErrorsHandler) ->
  'ngInject'
  
  vm = this

  vm.product = {}

  # Get the product
  MnoeProducts.get($stateParams.productId).then(
    (response) ->
      vm.product = response.data.plain()
  )

  vm.submitProduct = () ->
    vm.isLoading = true
    if vm.product.status == 'mnoe_admin_panel.dashboard.edit_product.published' then vm.product.active = true
    if vm.product.status == 'mnoe_admin_panel.dashboard.edit_product.draft' then vm.product.active = false

    MnoeProducts.update(vm.product).then(
      (response) ->
        toastr.success('mnoe_admin_panel.dashboard.edit_product.success', {extraData: {product: vm.product.name}})
        response = response.data.plain()
        # Go to products screen
        $state.go('dashboard.products')
      (error) ->
        $document.scrollTopAnimated(0)
        toastr.error('mnoe_admin_panel.dashboard.edit_product.error', {extraData: {organization_name: vm.organization.name}})
        MnoErrorsHandler.processServerError(error, vm.form)
    ).finally(-> vm.isLoading = false)

  return vm
