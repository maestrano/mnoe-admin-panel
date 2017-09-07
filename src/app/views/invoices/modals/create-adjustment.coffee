@App.controller 'CreateAdjustmentController', ($uibModalInstance) ->
  'ngInject'
  vm = this

  vm.adjustment = {}
  vm.closeModal = () ->
    $uibModalInstance.dismiss('cancel')

  vm.createAdjustment = () ->
    $uibModalInstance.close(vm.adjustment)

  return
