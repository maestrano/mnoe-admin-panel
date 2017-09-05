@App.controller 'EditAdjustmentController', ($uibModalInstance, adjustment) ->
  'ngInject'
  vm = this
  
  vm.adjustment = adjustment
  
  vm.closeModal = () ->
    $uibModalInstance.dismiss('cancel')

  return
