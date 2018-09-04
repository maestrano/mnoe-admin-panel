@App.controller 'DeleteProductController', ($uibModalInstance, MnoeProducts, product, MnoeMarketplace) ->
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
        MnoeMarketplace.clearApps()
        $uibModalInstance.close(true)
    ).finally(-> vm.modal.loading = false)

  return vm
