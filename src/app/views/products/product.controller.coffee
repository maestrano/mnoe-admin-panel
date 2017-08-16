@App.controller 'ProductController', ($stateParams, MnoeProducts) ->
  'ngInject'

  vm = this

  # Get the product
  MnoeProducts.get($stateParams.productId).then(
    (response) ->
      vm.product = response.data.plain()
  )
  return vm
