@App.controller 'EditAdjustmentController', ($uibModalInstance, adjustment) ->
  'ngInject'
  vm = this
  
  vm.adjustment = adjustment
  
  vm.closeModal = () ->
    $uibModalInstance.close()

  vm.createAdjustment = () ->
    $uibModalInstance.close(vm.adjustment)

  return
