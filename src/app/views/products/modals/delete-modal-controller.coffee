@App.controller 'DeleteProductController', ($uibModalInstance, MnoeProducts, product) ->
  'ngInject'
  
  vm = this
  vm.product = product
  vm.modal = {}
  
  vm.close = ->
    $uibModalInstance.close()

  vm.delete = () ->
    vm.modal.loading = true
    MnoeProducts.remove(vm.product.id).then(
      (success) ->
        $uibModalInstance.close(true)
    ).finally(-> vm.modal.loading = false)

  return vm
