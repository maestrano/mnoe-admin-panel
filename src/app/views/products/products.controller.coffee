@App.controller 'ProductsController', (MnoeProducts, $state) ->
  'ngInject'
  
  vm = this
  vm.product = {}

  vm.createProduct = () ->
    vm.product.name = ' '
    MnoeProducts.create(vm.product).then(
      (response) ->
        response = response.data.plain()
        vm.productId = response.product.id
        $state.go('dashboard.product',({productId: vm.productId}))
      (error) ->
    ).finally(-> vm.isLoading = false )

  return vm
